# ft_server (2021.02.18)

## 도커 명령어

<br>

### 1. 도커 설치

<br>

> 도커 홈페이지에서 `Docker for Mac` 설치.

* `Docker Toolbox` 로 설치할 시 `Docker for Mac` 과 다르게 리눅스 가상 머신을 생성한 후 도커를 설치하게 된다. 과정이 좀 더 복잡해지므로, `Docker for Mac` 를 설치하는 편이 좋다.   

<br>

> 설치한 도커 버전 확인하기

```sh
docker -v
```

<br><br><br>

### 2. 도커 컨테이너 생성하기    

<br>

> `run`

```docker
docker run -i -t --name ft_server -p 80:80 -p 443:443  debian:buster
```    
* `-i` : 컨테이너와 상호입출력을 가능하게 하는 옵션   
* `-t` : `tty` 를 활성화하여 `bash` 셸을 사용하도록 하는 옵션   
* `--name [컨테이너 이름]` : 컨테이너의 이름을 설정하는 옵션. 현재 컨테이너의 이름은 `ft_server`.   
* `-p [호스트 포트]:[컨테이너 포트]` : 컨테이너의 포트를 호스트의 포트와 바인딩해 연결할 수 있게 설정하는 옵션. (컨테이너를 외부에 노출)   
* `debian:buster` : 리눅스 OS 종류 중 하나로, 컨테이너를 생성하기 위한 이미지의 이름이다.   

<br><br>

> `pull` & `images`
```sh
docker pull debian:buster
docker images
```   
* `pull` : 이미지를 내려받을 때 사용하는 명령어   
* `images` : 도커 엔진에 존재하는 이미지의 목록을 출력해주는 명령어   

<br><br>

> `create` & `start` & `attach`

```sh
docker create -i -t --name ft_server -p 80:80 -p 443:443  debian:buster
docker start ft_server
docker attach ft_server
```    
* `run` 명령어는 `pull`, `create`, `start` 명령어를 일괄적으로 실행한 후 `attach` 가 가능한 컨테이너라면 컨테이너 내부로 들어간다. 이때, `pull`은 이미지가 없을 때만 실행되며, `create` 명령어 또한 `pull` 명령어를 포함하고 있다. 따라서 `run`을 활용한 첫번째 코드와 현재 코드는 같은 의미의 코드이다. 둘 중 원하는 코드로 도커 컨테이너를 생성하면 된다.    

<br><br><br>   

### 3. 기타 도커 명령어들    

<br>

> 컨테이너를 정지하고 빠져나오기

```docker
exit
```   
* `exit` 명령어를 이용하면, 실행중인 컨테이너를 빠져나올 수 있다. 다시 컨테이너를 실행시키고, 그 내부로 들어가고 싶다면, `start` 와 `attach` 명령어를 차례로 이용하면 된다.   

<br>

> 컨테이너 이름 변경하기

```docker
docker rename [기존 이름] [새로운 이름]
```   

<br>

> 컨테이너의 전체 ID 출력하기

```docker
docker inspect [컨테이너 이름] | grep Id
```   

<br>

> 컨테이너 삭제하기

```docker
docker stop [컨테이너 ID/이름]
docker rm [컨테이너 ID/이름]
```   
* 실행중인 컨테이너는 멈춘 후 삭제해야한다.   

<br>

> 실행 중인 컨테이너를 중지하는 과정없이 삭제하기
```docker
docker rm -f [컨테이너 ID/이름]
```   

<br>

> 모든 컨테이너 삭제
```docker
docker container prune
```   

```docker
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
```   
* `docker ps` : (정지되지 않은) 컨테이너 목록을 확인하는 명령어   
* `-a` : 정지된 컨테이너를 포함한 모든 컨테이너를 출력하는 옵션   
* `-q` : 컨테이너의 ID만 출력하는 옵션   

<br><br><br>   

### 4. Dockerfile   

> Dockerfile 내용      
```dockerfile
FROM 	debian:buster

LABEL	maintainer="jwoo <jwoo@student.42seoul.kr>"

RUN		mkdir ft_server_srcs && \
			apt-get update && apt-get -y upgrade && \
			apt-get -y install \
			nginx \
			curl \
			openssl \
			vim \
			php-fpm \
			mariadb-server \
			php-mysql \
			php-mbstring \
			wget

COPY	./srcs/run.sh ./
COPY	./srcs/default ./ft_server_srcs
COPY	./srcs/wp-config.php ./ft_server_srcs
COPY	./srcs/config.inc.php ./ft_server_srcs
COPY	./srcs/phpMyAdmin-5.0.4-all-languages.tar.gz ./
COPY	./srcs/latest.tar.gz ./

RUN		tar -xvf phpMyAdmin-5.0.4-all-languages.tar.gz && tar -xvf latest.tar.gz && \
			mv phpMyAdmin-5.0.4-all-languages phpmyadmin &&	mv phpmyadmin ./var/www/html/ && \
			mv wordpress/ ./var/www/html/ && \
			cp -rp ./ft_server_srcs/default ./etc/nginx/sites-available/ && \
			cp -rp ./ft_server_srcs/config.inc.php ./var/www/html/phpmyadmin/ &&\
			cp -rp ./ft_server_srcs/wp-config.php ./var/www/html/wordpress/

EXPOSE	80 443

CMD		bash run.sh
```   
* `FROM` : 생성할 이미지의 베이스가 될 이미지를 뜻함. (이 과제에서는 `debian:buster` 가 된다.) 이 명령어는 도커파일을 작성할 때 반드시 한 번 이상 입력해야 하며, 이미지 이름의 포맷은 `docker run` 명령어에서 이미지 이름을 사용했을 때와 같다. 사용하려는 이미지가 도커에 없다면 자동으로 `pull` 한다.   
<br>

* `LABEL` : 이미지에 메타데이터를 추가한다. 메타데이터는 '키:값'의 형태로 저장되며, 여러 개의 메타데이터가 저장될 수 있다. 추가된 메타데이터는 `docker inspect` 명령어로 이미지의 정보를 구해서 확인 할 수 있다.     
	* `maintainer` : 이미지를 생성한 개발자의 정보를 입력한다. 일번 적으로 도커파일을 작성한 사람과 연락할 수 있는 이메일 등을 입력한다.    
	* 사용법 : `LABEL	maintainer="[도커파일을 작성한 사람의 정보]"`    
<br>

* `RUN` : 이미지를 만들기 위해 컨테이너 내부에서 명령어를 실행한다. `RUN` 명령어를 사용할 때마다 이미지 레이어가 생성되므로, 이미지레이어를 여러층으로 만들고 싶지 않은 경우, `&&`로 명령어를 묶어 사용해야 한다. 그리고 도커파일을 이미지로 빌드하는 과정에서는 별도의 입력이 불가능하기 때문에 별도의 입력을 받아야하는 `RUN` (예를 들어서 `install` 할 때, `yes` 를 입력해줘야하는 경우, 이때는 `install -y` 옵션으로 미리 `yes`를 입력해준다.) 이 있다면 빌드 명령어는 이를 오류로 간주하고 빌드를 종료한다.   
<br>

* `COPY` : `srcs` 폴더에 있는 필요한 파일들을 컨테이너 안으로 복사해넣기 위해 필요한 명령어   
<br>

* `EXPOSE` : 도커파일의 빌드로 생성된 이미지에서 노출한 포트를 설정한다. 그러나 반드시 적은 포트들이 호스트의 포트와 바인딩되는 것은 아니며, 단지 컨테이너의 어떤 포트를 사용할 것임을 나태내는 것 뿐이다. 실제로 포트를 연결하려면 `docker run -p` 명령어와 옵션을 사용하여 컨테이너를 시작해야한다.   
<br>

* `CMD` : 컨테이너가 시작될 때마다 실행할 명령어를 설정하며, 도커파일에서 한 번만 사용할 수 있다. `CMD`는 `docker run` 명령어의 이미지 이름 뒤에 입력하는 커맨드와 같은 역할을 하지만 `docker run` 명령어에서 커맨드 명령줄 인자를 입력하면 도커파일에서 사용한 `CMD`는 `run` 커맨드로 덮어 쓰인다. (`CMD		bash run.sh` 는 `docker run -i -t -p 80:80 -p 443:443 debian:buster bash run.sh` 와 같다.)   