# micro-amazon

마이크로서비스 오픈소스를 활용한 쿠버네티스 미니 프로젝트

# Addition

- [29-admin-dep.yaml](https://github.com/micro-amazon/micro-amazon/blob/master/deploy/kubernetes/manifests/29-admin-dep.yaml)
- [30-admin-svc.yaml](https://github.com/micro-amazon/micro-amazon/blob/master/deploy/kubernetes/manifests/30-admin-svc.yaml)
- [31-admin-db-dep.yaml](https://github.com/micro-amazon/micro-amazon/blob/master/deploy/kubernetes/manifests/31-admin-db-dep.yaml)
- [32-admin-db-svc.yaml](https://github.com/micro-amazon/micro-amazon/blob/master/deploy/kubernetes/manifests/32-admin-db-svc.yaml)
- [admin-hsc.yml](https://github.com/micro-amazon/micro-amazon/blob/master/deploy/kubernetes/autoscaling/admin-hsc.yml)

# Architecture Diagram

![Untitled](https://raw.githubusercontent.com/micro-amazon/micro-amazon/master/internal-docs/architecture-diagram.png)

기존 오픈소스에 적용할 수 있는 마이크로 서비스 admin을 추가 개발하고, Jenkins를 구축한다. 

이를 통해 쿠버네티스 서비스가 지속적 통합, 제공이 가능하게 한다.

1. Gitihub에 code를 업로드하면, 쿠버네티스 클러스터 내 Jenkins가 작동한다.
2. Jenkins Piepeline을 따라 Docker Hub에 Docker Image를 build/push한다. 
3. Docker Hub에서 pull한 이미지를 쿠버네티스 클러스터 내에 배포한다.

# Kubernetes Architecture Diagram

![Untitled](https://raw.githubusercontent.com/micro-amazon/micro-amazon/master/internal-docs/k8s-architecture-diagram.png)

- admin(Spring)
    - HPA
    - Deployment
    - Service
- admin-db(Mongo-DB)
    - Deployment
    - Service

# Set up

## micro-amazon

- git clone
    
    ```bash
    git clone https://github.com/micro-amazon/micro-amazon.git
    ```
    
- minikube 설치
    
    [https://minikube.sigs.k8s.io/docs/start/](https://minikube.sigs.k8s.io/docs/start/)
    
- kubectl 설치
    
    [https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-linux/](https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-linux/)
    
- (선택) docker 설치, sudo 권한 부여
    
    [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)
    
    - Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/version": dial unix /var/run/docker.sock: connect: permission denied
        
        [https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)
        

- 쿠버네티스 클러스터 실행
    
    ```bash
    sudo -E minikube start --driver=none
    kubectl create -f micro-amazon/deploy/kubernetes/complete-demo.yaml
    ```
    
    - 개발환경에 따라 driver는 달라질 수 있으나, 일반적으로 가상머신 위에서 사용 시 driver는 none으로 설정하는 것이 좋습니다.
        
        [https://minikube.sigs.k8s.io/docs/drivers/none/](https://minikube.sigs.k8s.io/docs/drivers/none/)
        
    - X Exiting due to GUEST_MISSING_CONNTRACK: Sorry, Kubernetes 1.22.3 requires conntrack to be installed in root's path
        
        [https://github.com/manusa/actions-setup-minikube/issues/33](https://github.com/manusa/actions-setup-minikube/issues/33)
        

- (선택)포트포워딩
    
    minikube의 driver를 docker 등으로 설정하였을 경우, 포트포워딩을 해주어야 합니다.
    
    [Access an application running on NodePort of minikube inside an EC2 instance from outside world](https://stackoverflow.com/questions/59936139/access-an-application-running-on-nodeport-of-minikube-inside-an-ec2-instance-fro)
    
    ```bash
    kubectl port-forward --address 0.0.0.0 svc/front-end --namespace="sock-shop" 30001:80
    ```
    

## jenkins

- 젠킨스 설치
    
    ```bash
    micro-amazon/install/jenkins/jenkins-install.sh
    ```
    
    [https://medium.com/@jyson88/kubernetes-helm-jenkins-사용-a4cb11e3b612](https://medium.com/@jyson88/kubernetes-helm-jenkins-%EC%82%AC%EC%9A%A9-a4cb11e3b612)
    
- 젠킨스 플러그인 설치
    - [Docker Pipeline](https://plugins.jenkins.io/docker-workflow)
    - [Docker plugin](https://plugins.jenkins.io/docker-plugin)
    - [GitHub Integration Plugin](https://plugins.jenkins.io/github-pullrequest)
    - [Gradle Plugin](https://plugins.jenkins.io/gradle)
    - [Kubernetes](https://plugins.jenkins.io/kubernetes)
    - [Kubernetes CLI Plugin](https://plugins.jenkins.io/kubernetes-cli)

- Credentials 설정
    - github-access-token (Username with password)
    - DOCKER_HUB_AUTH (Secret text)
        
        [https://twofootdog.tistory.com/13](https://twofootdog.tistory.com/13)
        
    - jenkins-robot-token (Secret text)
        
        [https://plugins.jenkins.io/kubernetes-cli/#plugin-content-generating-kubernetes-credentials](https://plugins.jenkins.io/kubernetes-cli/#plugin-content-generating-kubernetes-credentials)
        

# Usage

- micro-amazon 접속
    
    ```bash
    http://{host-url}:30001
    ```
    
- Jenkins 접속
    
    ```bash
    http://{host-url}:8080
    ```
    
    cf. 포트포워딩이 정상적으로 동작하지 않았을 경우 다시 포트포워딩을 해준다.
    
    ```bash
    kubectl port-forward --address 0.0.0.0 svc/jenkins 8080:8080 &
    ```