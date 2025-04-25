# 🚀 Instrucciones para configurar un clúster de Redis en RKE2

> **Recomendación inicial**: elimina las máquinas virtuales y volúmenes de intentos fallidos para evitar agotar los recursos disponibles.

---

## 1. Configurar `provider.tf`

```terraform
provider "openstack" {
  user_name   = "azangla"
  tenant_name = "project_azangla"
  domain_name = "sistemas_distribuidos"
  auth_url    = "http://keystone.cumulus.ingenieria.uncuyo.edu.ar/v3"
  region      = "RegionOne"
}
```

---

## 2. Configurar `main.tf`

### Añadir tu clave pública

```terraform
resource "openstack_compute_keypair_v2" "keypair" {
  name       = "keypair"
  public_key = "ssh-ed25519 AAAAC3Nza... adrzanbar@gmail.com"
}
```

### Crear el grupo de seguridad desde Horizon

(Sigue la guía de Trabajos Prácticos Nº 3 para permitir tráfico TCP). En este ejemplo el grupo se llama `tcp`

### Definir instancias

#### Servidor RKE2

```terraform
resource "openstack_compute_instance_v2" "rke2-server" {
  ...
  security_groups = ["default", "tcp"]
  ...
}
```

#### Agentes RKE2

```terraform
resource "openstack_compute_instance_v2" "rke2-agent" {
  count = 2
  name  = "rke2-agent-${count.index + 1}"
  ...
  security_groups = ["default", "tcp"]
  ...
}
```

---

## 3. Aplicar la configuración

```bash
tofu init
tofu apply
```

---

## 4. Configurar el nodo servidor

### Obtener IP del servidor

```bash
openstack server list
```

### Ejecutar el script en el servidor

```bash
ssh debian@<IP del rke2-server> 'bash -s' < rke2_server.sh
```

⚠️ Al terminar la ejecución se imprime el contenido de:

- `/etc/rancher/rke2/rke2.yaml`
- `/var/lib/rancher/rke2/server/node-token`

🔐 Te recomiendo guardar el `token` en un .txt

💾 Pega el YAML en `~/.kube/config` y reemplaza la IP del servidor.

### Ejecutar agentes

Necesitarás pasar como parámetros la IP del nodo rke2-server y el `token` del paso anterior

```bash
ssh debian@<IP del rke2-agent> 'bash -s' < rke2_agent.sh <IP del rke2-server> <token>
```

Haz lo mismo para el segundo agente.

---

## 5. (Opcional) Verificar con Kanboard

```bash
kubectl apply -f practica-intro-k8s/ejemplo1-kanboard/
kubectl get pods
kubectl port-forward service/ejemplo1-kanboard 8080:80
```

---

## 6. Desplegar Redis con Helm

Se asume que helm está instalado (Seguir la guía de trabajos práctivos Nº 5)

```bash
helm install my-release --set fullnameOverride="redis-cluster" oci://registry-1.docker.io/bitnamicharts/redis-cluster
```

```bash
export REDIS_PASSWORD=$(kubectl get secret --namespace "default" redis-cluster -o jsonpath="{.data.redis-password}" | base64 -d)
```

💡 Este comando también se encuentra en `redis_password.txt`. Recuerda que si cierras la terminal, debes volver a ejecutarlo.

```bash
helm repo add cloud-provider-openstack https://kubernetes.github.io/cloud-provider-openstack/
```

### Configurar `cider_values.yaml` con tus credenciales

Para obtener el `tenant-id`:

```bash
openstack project list
```

Instalar el CSI driver:

```bash
helm install openstack-cinder-csi cloud-provider-openstack/openstack-cinder-csi --values=cider_values.yaml
```

---

## ⚠️ ¡NO EJECUTES ESTOS COMANDOS! ⚠️

❌🚫❗️ **NO LOS EJECUTES TODAVÍA.** En múltiples pruebas, estos comandos causaron fallas en la configuración del clúster Redis.

```bash
kubectl exec -it redis-cluster-0 -- redis-cli -a $REDIS_PASSWORD cluster info
```

```bash
kubectl exec -it redis-cluster-0 -- redis-cli -a $REDIS_PASSWORD --cluster check localhost:6379
```

🔍 Espera a que todos los pods estén corriendo correctamente:

```bash
kubectl get pods
kubectl get pvc
```

---

## 7. Desplegar `hit-counter` (una vez Redis esté funcionando)

```bash
kubectl apply -f hit-counter/manifests/app-deployment-service.yaml
kubectl get pods
kubectl port-forward service/hit-counter 8080:80
```

---
