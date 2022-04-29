# Martín Vedani | keepcoding-devops-liberando-productos-practica-final

## Objetivo

El objetivo es mejorar un proyecto inicial creado previamente para ponerlo en producción, a través de la adicción de una serie de mejoras.

## Proyecto a entregar

El proyecto mejorado es un servidor que realiza lo siguiente:

- Utiliza [FastAPI](https://fastapi.tiangolo.com/) para levantar un servidor en el puerto `8081` e implementa inicialmente dos endpoints:
  - `http://0.0.0.0:8081`: Devuelve en formato `JSON` como respuesta `{"message":"Hello World"}` y un status code 200.
  - `http://0.0.0.0:8081/health`: Devuelve en formato `JSON` como respuesta `{"health": "ok"}` y un status code 200.
  - `http://0.0.0.0:8081/bye`: Devuelve en formato `JSON` como respuesta `{"message": "Bye bye"}` y un status code 200.

- Se han implementado tests unitarios para el servidor [FastAPI](https://fastapi.tiangolo.com/)

- Utiliza [prometheus-client](https://github.com/prometheus/client_python) para arrancar un servidor de métricas en el puerto `8000` y poder registrar métricas, siendo inicialmente las siguientes:
  - `Counter('server_requests_total', 'Total number of requests to this webserver')`: Contador que se incrementará cada vez que se haga una llamada a alguno de los endpoints implementados por el servidor ( `/` + `/health` + `/bye` )
  - `Counter('main_requests_total', 'Total number of requests to main endpoint')`: Contador que se incrementará cada vez que se haga una llamada al endpoint `/`.
  - `Counter('healthcheck_requests_total', 'Total number of requests to healthcheck')`: Contador que se incrementará cada vez que se haga una llamada al endpoint `/health`.
  - `Counter('goodbye_requests_total', 'Total number of requests to goodbye endpoint')`: Contador que se incrementará cada vez que se haga una llamada al endpoint `/bye`.

## Software necesario

Es necesario disponer del siguiente software:

- `Python` en versión `3.8.5` o superior, disponible para los diferentes sistemas operativos en la [página oficial de descargas](https://www.python.org/downloads/release/python-385/)

- `virtualenv` para poder instalar las librerías necesarias de Python, se puede instalar a través del siguiente comando:

- `Docker` para poder arrancar el servidor implementado a través de un contenedor Docker, es posible descargarlo a [través de su página oficial](https://docs.docker.com/get-docker/).

## Ejecución de servidor

Primero que nada, ingresar a la carpeta   `z.Entrega`

```sh
cd z.Entrega/
```

## Ejecución directa con Python

1. Instalación de un virtualenv, **realizarlo sólo en caso de no haberlo realizado previamente**:

   a. Obtener la versión actual de Python instalada para crear posteriormente un virtualenv:

    ```sh
    python3 --version
    ```

    El comando anterior mostrará algo como lo mostrado a continuación:

    ```sh
    Python 3.10.4
    ```

    ```sh
    pip3 install virtualenv
    ```

    En caso de estar utilizando Linux y el comando anterior diera fallos se debe ejecutar el siguiente comando utilizando `3.#` (donde # es la version local de su ordenador):

    ```sh
    sudo apt-get update && sudo apt-get install -y python3.10-venv
    ```

   b. Crear de virtualenv en la raíz del directorio para poder instalar las librerías necesarias:

    - En caso de en el comando anterior haber obtenido `Python 3.10.*`

    ```sh
    python3.10 -m venv venv
    ```

    - En caso de en el comando anterior haber obtenido `Python 3.9.*`:

    ```sh
    python3.9 -m venv venv
    ```

2. Activar el virtualenv creado en el directorio `venv` en el paso anterior:

    ```sh
    source venv/bin/activate
    ```

3. Instalar las librerías necesarias de Python, recogidas en el fichero `requirements.txt`, **sólo en caso de no haber realizado este paso previamente**. Es posible instalarlas a través del siguiente comando:

    ```sh
    pip3 install -r requirements.txt
    ```

4. Ejecución del código para arrancar el servidor:

    ```sh
    python3 src/app.py
    ```

5. La ejecución del comando anterior debería mostrar algo como lo siguiente:

    ```sh
    [2022-04-16 09:44:22 +0000] [1] [INFO] Running on http://0.0.0.0:8081 (CTRL + C to quit)
    ```

## Ejecución a través de un contenedor Docker

1. Crear una imagen Docker con el código necesario para arrancar el servidor:

    ```sh
    docker build -t simple-server:0.0.2 .
    ```

2. Renombrarla y subirla a DockerHub

    ```sh
    docker tag simple-server:0.0.2 martinved/simple-server:0.0.2 &&\
    docker push martinved/simple-server:0.0.2
    ```

    Nota: Sin credenciales no puedes usar mi nombre, deberás usar otro repositorio propio. Mi repositorio es público para bajar imágenes por lo que no hace falta que también actualices este valor en el archivo values.yaml que alimenta lo que haremos con helm en algunos pasos más adelante.

4. Se ha automatizado la creación de este release ǜ0.0.2` en el repository de imágenes docker de GitHub (ver `.github/workflows/release.yaml`), el cuál es muy parecido a Docker Hub pero privado en mi caso, y se ha conseguido el siguiente resultado luego de hace el git push con "tags" utilizando los siguientes comandos:

    ```sh
    git add -A &&\
    git commit -m "publish version v0.0.2" &&\
    git push origin main
    ```

    And then run:

    ```sh
    git tag -a v0.0.2 -m "publish version v0.0.2" &&\
    git push origin --tags
    ```
    
![release and docker image build](https://user-images.githubusercontent.com/13549294/165978644-2a7c42d4-637a-42df-889f-68a76deb32d7.png)

1. Lo siguiente es inicializar la imagen construida en los pasos anteriores mapeando los puertos utilizados por el servidor de FastAPI y el cliente de prometheus:

    ```sh
    docker run --rm -d -p 8000:8000 -p 8081:8081 --name simple-server simple-server:0.0.2
    ```

2. Obtener los logs del contenedor creado en el paso anterior:

    ```sh
    docker logs -f simple-server
    ```

3. La ejecución del comando anterior debería mostrar algo como lo siguiente:

    ```sh
    [2022-04-16 09:44:22 +0000] [1] [INFO] Running on http://0.0.0.0:8081 (CTRL + C to quit)
    ```

## Comprobación de endpoints de servidor y métricas

Una vez arrancado el servidor, utilizando cualquier de las formas expuestas en los apartados anteriores, es posible probar las funcionalidades implementadas por el servidor:

- Comprobación de servidor FastAPI, a través de llamadas a los diferentes endpoints:

  - Realizar una petición al endpoint `/`

      ```sh
      curl -X 'GET' \
      'http://0.0.0.0:8081/' \
      -H 'accept: application/json'
      ```

      Debería devolver la siguiente respuesta:

      ```json
      {"message":"Hello World"}
      ```

  - Realizar una petición al endpoint `/health`

      ```sh
      curl -X 'GET' \
      'http://0.0.0.0:8081/health' \
      -H 'accept: application/json'
      ```

      Debería devolver la siguiente respuesta.

      ```json
      {"health": "ok"}
      ```

  - Realizar una petición al endpoint `/bye`

      ```sh
      curl -X 'GET' \
      'http://0.0.0.0:8081/bye' \
      -H 'accept: application/json'
      ```

      Debería devolver la siguiente respuesta.

      ```json
      {"msg":"Bye Bye"}
      ```

- Comprobación de registro de métricas, si se accede a la URL `http://0.0.0.0:8000` se podrán ver todas las métricas con los valores actuales en ese momento:

  - Realizar varias llamadas al endpoint `/` y ver como el contador utilizado para registrar las llamadas a ese endpoint, `main_requests_total` ha aumentado, se debería ver algo como lo mostrado a continuación:

    ```sh
    # TYPE main_requests_total counter
    main_requests_total 1.0
    ```

  - Realizar varias llamadas al endpoint `/health` y ver como el contador utilizado para registrar las llamadas a ese endpoint, `healthcheck_requests_total` ha aumentado, se debería ver algo como lo mostrado a continuación:

    ```sh
    # TYPE healthcheck_requests_total counter
    healthcheck_requests_total 1.0    #(o más, los health checks son automáticos)
    ```

    - Realizar varias llamadas al endpoint `/bye` y ver como el contador utilizado para registrar las llamadas a ese endpoint, `goodbye_requests_total` ha aumentado, se debería ver algo como lo mostrado a continuación:

    ```sh
    # TYPE goodbye_requests_total counter
    goodbye_requests_total 1.0
    ```

  - También se ha credo un contador para el número total de llamadas al servidor `server_requests_total`, por lo que este valor debería ser la suma de los dos anteriores, tal y como se puede ver a continuación:

    ```sh
    # TYPE server_requests_total counter
    server_requests_total 4.0 #(o más, ya que como mencionamos, los health checks son automáticos y suman al total)
    ```

## Tests

Se ha implementado tests unitarios para probar el servidor FastAPI, estos están disponibles en el archivo `src/tests/app_test.py`.

Es posible ejecutar los tests manualmente de diferentes formas:

- Ejecución de todos los tests:

    ```sh
    pytest
    ```

- Ejecución de todos los tests y mostrar cobertura:

    ```sh
    pytest --cov
    ```

- Ejecución de todos los tests y generación de report de cobertura:

    ```sh
    pytest --cov --cov-report=html
    ```

- Se puede ya apagar el contenedor de docker con nuestro `simple-server` ya que en los siguientes pasos seguiremos con Kubernetes utilizando minikube

  ```sh
  docker stop simple-server
  ```
Así mismo, se han automatizado los testeos en cada `git push` con GitHub Actions (ver `.github/workflows/test.yaml`) con el siguiente resultado exitoso:

![test con GitHubActions](https://user-images.githubusercontent.com/13549294/165978702-073915e2-b212-43de-9310-ea2a43d2a240.png)

# Monitoring-Autoscaling

## Objetivo

El objetivo de este laboratorio es realizar ejemplos prácticos con monitorización mediante el stack de Prometheus, utilizando el chart kube-prometheus-stack para ello.

También se realizarán ejemplos prácticos con autoescalado en Kubernetes, se realizará tanto autoescalado basado en métricas de CPU y Memoria como basado en eventos, viendo así las ventajas y desventajas de cada uno.

## Software necesario

- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [helm](https://helm.sh/docs/intro/install/)

1. Crear un cluster de Kubernetes de la versión `v1.21.1` utilizando minikube:

    ```sh
    minikube start --kubernetes-version='v1.21.1' \
        --memory=4096 \
        -p monitoring-demo
    ```

2. Añadir el repositorio de helm `prometheus-community` para poder desplegar el chart `kube-prometheus-stack`:

    ```sh
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts &&\
    helm repo update
    ```

3. Desplegar el chart `kube-prometheus-stack` del repositorio de helm añadido en el paso anterior con los valores configurados en el archivo `custom_values_prometheus.yaml` en el namespace `monitoring`:

    ```sh
    helm -n monitoring upgrade --install prometheus prometheus-community/kube-prometheus-stack \
                                -f custom_values_prometheus.yaml \
                                --create-namespace --wait --version 34.1.1
    ```

- Con paciencia, luego de un corto tiempo, debería devolver la siguiente respuesta.

    ```sh
    Release "prometheus" has been upgraded. Happy Helming!
    NAME: prometheus
    LAST DEPLOYED: Thu Apr 28 18:10:39 2022
    NAMESPACE: monitoring
    STATUS: deployed
    REVISION: 2
    NOTES:
    kube-prometheus-stack has been installed. Check its status by running:
      kubectl --namespace monitoring get pods -l "release=prometheus"
    ```

4. Añadir el repositorio de helm de bitnami para poder desplegar el chart de mongodb empaquetado por esta compañía:

    ```sh
    helm repo add bitnami https://charts.bitnami.com/bitnami &&\
    helm repo update
    ```

5. Instalar metrics-server en minikube a través de la activación del addon necesario:

    ```sh
    minikube addons enable metrics-server -p monitoring-demo
    ```

### Despliegue de aplicación simple-fast-api

Se ha creado un helm chart en la carpeta `fast-api-webapp` para la aplicación `simple-server:0.0.2` desarrollada anteriormente, en la cual se han realizado modificaciones respecto a las versiones anteriores para disponer de métricas mediante prometheus. Para desplegarla es necesario realizar los siguientes pasos:

1. Descargar las dependencias necesarias, siendo en este caso el chart de mongodb

    ```sh
    helm dep up fast-api-webapp
    ```

2. Desplegar el helm chart:

    ```sh
    helm -n fast-api upgrade my-app --install --create-namespace fast-api-webapp
    ```

- Debería devolver la siguiente respuesta.

    ```sh
    Release "my-app" has been upgraded. Happy Helming!
    NAME: my-app
    LAST DEPLOYED: Thu Apr 28 19:12:30 2022
    NAMESPACE: fast-api
    STATUS: deployed
    REVISION: 2
    NOTES:
    1. Get the application URL by running these commands:
        export POD_NAME=$(kubectl get pods --namespace fast-api -l "app.kubernetes.io/name=fast-api-webapp,app.kubernetes.io/instance=my-app" -o jsonpath="{.items[0].metadata.name}")
        export CONTAINER_PORT=$(kubectl get pod --namespace fast-api $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
        echo "Visit http://127.0.0.1:8080 to use your application"
        kubectl --namespace fast-api port-forward $POD_NAME 8080:$CONTAINER_PORT
    ```

3. En una misma terminal para no perder las variables de entorno, ejecuta los comandos de las NOTAS anteriores:

    ```sh
    export POD_NAME=$(kubectl get pods --namespace fast-api -l "app.kubernetes.io/name=fast-api-webapp,app.kubernetes.io/instance=my-app" -o jsonpath="{.items[0].metadata.name}") &&\
    export CONTAINER_PORT=$(kubectl get pod --namespace fast-api $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}") &&\
    kubectl --namespace fast-api port-forward $POD_NAME 8081:$CONTAINER_PORT
    ```

    Nota: El comando `echo $CONTAINER_PORT` debería retornar 8081 (debe quedar 8081:8081, no 8080:8080 como en las notas). Con lo cual deberíamos poder acceder a nuestra aplicación accediendo a la url http://127.0.0.1:8081 

    - Abrir otra venta de terminal y observar los pods creados en el namespace donde se ha desplegado fast-api server:

      ```sh
      kubectl -n fast-api get po -w
      ```

    - Abrir otra venta adicional de terminal y observar el escalado horizontal de pods de nuestra fast-api server:

      ```sh
      kubectl -n fast-api get hpa -w
      ```

    - En un nueva ventana más, ejecutar el script the stress a nuestra a fast-api y ver lo que ocurre con los pods de Kubernetes

      ```sh
      chmod +x stress_script.sh && ./stress_script.sh
      ```

      Nota:  el impacto no es significativo. Veremos otro método más adelante con el que veremos el escalado horizontal claramente.

4. Abrir una nueva pestaña en la terminal y realizar un port-forward del servicio de Grafana al puerto 3000 de la máquina:

    ```sh
    kubectl -n monitoring port-forward svc/prometheus-grafana 3000:80
    ```

5. Abrir otra pestaña en la terminal y realizar un port-forward del servicio de Prometheus al puerto 9090 de la máquina:

    ```sh
    kubectl -n monitoring port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
    ```

6. Ya realizamos un port-forwar al `Service` creado para nuestro servidor en el paso número 3. El comando otra vez (sin variables) sería el siguiente:

    ```sh
    kubectl -n fast-api port-forward svc/my-app-fast-api-webapp 8081:8081
    ```

7. Acceder a la dirección <http://localhost:3000> del navegador para acceder a Grafana, las credenciales por defecto son `admin` para el usuario y `prom-operator` para la contraseña.

8. Acceder a la dirección <http://localhost:9090> para acceder al Prometheus, **por defecto no se necesita autenticación**.

9. Empezar a realizar diferentes peticiones al servidor de fastapi, es posible a través de la URL <http://localhost:8081/docs> utilizando swagger

10. Acceder al dashboard creado para observar las peticiones al servidor a través de la URL <http://localhost:3000/dashboards>, seleccionando una vez en ella la opción Import y en el siguiente paso seleccionar **Upload JSON File** y seleccionar el archivo presente en esta carpeta llamado `custom_dashboard.json`.

11. Obtener el pod creado en el paso 1 para poder lanzar posteriormente un comando de prueba de extres:

    ```sh
    export POD_NAME=$(kubectl get pods --namespace fast-api -l "app.kubernetes.io/name=fast-api-webapp,app.kubernetes.io/instance=my-app" -o jsonpath="{.items[0].metadata.name}")
    ```

12. Acceder mediante una shell interactiva al pod obtenido en el paso anterior:

    ```sh
    kubectl -n fast-api exec --stdin --tty $POD_NAME -- /bin/sh
    ```

13. Dentro de la shell en la que se ha accedido en el paso anterior instalar y utilizar los siguientes comandos para descargar un proyecto de github que realizará pruebas de extress:

    a. Instalar los binarios necesarios en el pod

    ```sh
    apk update && apk add git go
    ```

    b. Descargar el repositorio de github y acceder a la carpeta de este, donde se realizará la compilación:

    ```sh
    git clone https://github.com/jaeg/NodeWrecker.git &&\
    cd NodeWrecker &&\
    go build -o extress main.go
    ```

    c. Ejecución del binario obtenido de la compilación del paso anterior que realizará una prueba de extress dentro del pod:

    ```sh
    ./extress -abuse-memory -escalate -max-duration 10000000
    ```

14. Abrir una nueva pestaña en la terminal y ver como evoluciona el HPA creado para la aplicación web:

    ```sh
    kubectl -n fast-api get hpa -w
    ```

15. Se debería recibir una notificación como la siguiente en el canal de Slack configurado:

    ```sh
    [RESOLVED] Monitoring Event Notification
    Alert: fastApiConsumingMoreThanRequest - critical
    Description: Pod my-app-fast-api-webapp-975fbcb99-gzhc6) is consuming more than requested
    Graph: :gráfico_con_tendencia_ascendente: Runbook: <|:cuaderno_de_espiral:>
    Details:
    • alertname: fastApiConsumingMoreThanRequest
    • pod: my-app-fast-api-webapp-975fbcb99-gzhc6
    • prometheus: monitoring/prometheus-kube-prometheus-prometheus
    • severity: critical
    Mostrar menos
    ```
    
![slack alert channel](https://user-images.githubusercontent.com/13549294/165846765-68220d6d-0cb1-4949-bc9c-1ff91933119e.png)

16. Del tablero generado por el archivo JSON importamos a Grafana en el paso 10, podemos ver la siguiente demostración donde manualmente hice 9 llamadas al endpoint `/bye` en el paso 9 con Swagger, y 2143 llamadas automáticas al endpoint principal `/` en el paso 13:

![grafana dashboard](https://user-images.githubusercontent.com/13549294/165847102-6aa46b75-a327-4a89-a035-a2388782bdc1.png)


-----------------------------------------------------------------------------------------------------

## Practica a realizar

A partir del ejemplo inicial descrito en los apartados anteriores es necesario realizar una serie de mejoras:

Los requerimientos son los siguientes:

- Añadir por lo menos un nuevo endpoint a los existentes `/` y `/health`, un ejemplo sería `/bye` que devolvería `{"msg": "Bye Bye"}`, para ello será necesario añadirlo en el fichero [src/application/app.py](./src/application/app.py)

- Creación de tests unitarios para el nuevo endpoint añadido, para ello será necesario modificar el [fichero de tests](./src/tests/app_test.py)

- Opcionalmente creación de helm chart para desplegar la aplicación en Kubernetes, se dispone de un ejemplo de ello en el [laboratorio realizado en la clase 3](https://github.com/KeepCodingCloudDevops5/keepcoding-devops-liberando-productos/tree/main/labs/3-monitoring-autoscaling/fast-api-webapp)

- Creación de pipelines de CI/CD en cualquier plataforma (Github Actions, Jenkins, etc) que cuenten por lo menos con las siguientes fases:

  - Testing: tests unitarios con cobertura. Se dispone tanto de un [ejemplo con Github Actions en el repositorio actual](./.github/workflows/test.yaml) como de un [ejemplo de ejecución](https://github.com/KeepCodingCloudDevops5/keepcoding-devops-liberando-productos-practica-final/runs/6062566772?check_suite_focus=true)

  - Build & Push: creación de imagen docker y push de la misma a cualquier registry válido que utilice alguna estrategia de release para los tags de las vistas en clase, se recomienda GHCR ya incluido en los repositorios de Github

    Se dispone tanto de un [ejemplo con Github Actions en el repositorio actual](./.github/workflows/release.yaml) como de un [ejemplo de ejecución](https://github.com/KeepCodingCloudDevops5/keepcoding-devops-liberando-productos-practica-final/runs/6062569345?check_suite_focus=true)

- Configuración de monitorización y alertas:

  - Configurar monitorización mediante prometheus en los nuevos endpoints añadidos, por lo menos con la siguiente configuración:
    - Contador cada vez que se pasa por el/los nuevo/s endpoint/s, tal y como se ha realizado para los endpoints implementados inicialmente

  - Desplegar prometheus a través de Kubernetes mediante minikube y configurar alert-manager para por lo menos las siguientes alarmas, tal y como se [ha realizado en el laboratorio del día 3](https://github.com/KeepCodingCloudDevops5/keepcoding-devops-liberando-productos/tree/main/labs/3-monitoring-autoscaling) mediante el chart `kube-prometheus-stack`:
    - Uso de CPU de un contenedor mayor al del límite configurado, se puede utilizar como base el ejemplo utilizado en el laboratorio 3 para mandar alarmas cuando el contenedor de la aplicación `fast-api` [consumía más del asignado mediante request](https://github.com/KeepCodingCloudDevops5/keepcoding-devops-liberando-productos/blob/main/labs/3-monitoring-autoscaling/custom_values_prometheus.yaml#L141)

  - Las alarmas configuradas deberán tener severity high o critical

  - Crear canal en slack `<nombreAlumno>-prometheus-alarms` y configurar webhook entrante para envío de alertas con alert manager

  - Alert manager estará configurado para lo siguiente:
    - Mandar un mensaje a Slack en el canal configurado en el paso anterior con las alertas con label "severity" y "critical"
    - Deberán enviarse tanto alarmas como recuperación de las mismas
    - Habrá una plantilla configurada para el envío de alarmas

    Se ha realizado un ejemplo de ello en el laboratorio del día 3, en la [sección de configuración de alertmanager de los valores aplicados al chart](https://github.com/KeepCodingCloudDevops5/keepcoding-devops-liberando-productos/blob/main/labs/3-monitoring-autoscaling/custom_values_prometheus.yaml#L84).

    Para poder comprobar si esta parte funciona se recomienda realizar una prueba de estres, como la realizada en el [laboratorio 3](https://github.com/KeepCodingCloudDevops5/keepcoding-devops-liberando-productos/tree/main/labs/3-monitoring-autoscaling#despliegue-de-aplicaci%C3%B3n-simple-fast-api) a partir del paso 8.

  - Creación de un dashboard de Grafana, con por lo menos lo siguiente:
    - Número de llamadas a los endpoints
    - Número de veces que la aplicación ha arrancado

    Se puede utilizar como base el [dashboard](https://github.com/KeepCodingCloudDevops5/keepcoding-devops-liberando-productos/blob/main/labs/3-monitoring-autoscaling/custom_dashboard.json) utilizado en el laboratorio del día 3, importandolo y realizando los cambios necesarios

## Entregables

Se deberá entregar mediante un repositorio realizado a partir del original lo siguiente:

- Código de la aplicación y los tests modificados
- Ficheros para CI/CD configurados y ejemplos de ejecución válidos
- Ficheros para despliegue y configuración de prometheus de todo lo relacionado con este, así como el dashboard creado exportado a `JSON` para poder reproducirlo
- `README.md` donde se explique como se ha abordado cada uno de los puntos requeridos en el apartado anterior, con ejemplos prácticos y guía para poder reproducir cada uno de ellos
