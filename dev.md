# useful commands
## clean up docker
use it when docker says "There is no space left on device". It will remove built but not used images and other temporary files.
```
docker system prune -f
```

```
docker rm -f $(docker ps -qa)
```

## build container with no cache
```
docker-compose build --no-cache --progress=plain
```
## start iris container
```
docker-compose up -d
```

## open iris terminal in docker
```
docker exec iris iris session iris -U TOOL
```


## import objectscirpt code

do $System.OBJ.LoadDir("/home/irisowner/dev/src","ck",,1)
## map iris key from Mac home directory to IRIS in container
- ~/iris.key:/usr/irissys/mgr/iris.key

## install git in the docker image
## add git in dockerfile
USER root
RUN apt update && apt-get -y install git

USER ${ISC_PACKAGE_MGRUSER}


## install docker-compose
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

```

## load and test module
```

zpm "load /home/irisowner/dev"

zpm "test dc-sample"
```

## select zpm test registry
```
repo -n registry -r -url https://test.pm.community.intersystems.com/registry/ -user test -pass PassWord42
```

## get back to public zpm registry
```
repo -r -n registry -url https://pm.community.intersystems.com/ -user "" -pass ""
```

## export a global in runtime into the repo
```
d $System.OBJ.Export("GlobalD.GBL","/irisrun/repo/src/gbl/GlobalD.xml")
```

## create a web app in dockerfile
```
zn "%SYS" \
  write "Create web application ...",! \
  set webName = "/csp/irisweb" \
  set webProperties("NameSpace") = "TOOL" \
  set webProperties("Enabled") = 1 \
  set webProperties("CSPZENEnabled") = 1 \
  set webProperties("AutheEnabled") = 32 \
  set webProperties("iKnowEnabled") = 1 \
  set webProperties("DeepSeeEnabled") = 1 \
  set sc = ##class(Security.Applications).Create(webName, .webProperties) \
  write "Web application "_webName_" has been created!",!
```



```
do $SYSTEM.OBJ.ImportDir("/opt/irisbuild/src",, "ck")
```


### run tests described in the module

TOOL>zpm
TOOL:zpm>load /irisrun/repo
TOOL:zpm>test package-name

### install ZPM with one line
    // Install ZPM
    set $namespace="%SYS", name="DefaultSSL" do:'##class(Security.SSLConfigs).Exists(name) ##class(Security.SSLConfigs).Create(name) set url="https://pm.community.intersystems.com/packages/zpm/latest/installer" Do ##class(%Net.URLParser).Parse(url,.comp) set ht = ##class(%Net.HttpRequest).%New(), ht.Server = comp("host"), ht.Port = 443, ht.Https=1, ht.SSLConfiguration=name, st=ht.Get(comp("path")) quit:'st $System.Status.GetErrorText(st) set xml=##class(%File).TempFilename("xml"), tFile = ##class(%Stream.FileBinary).%New(), tFile.Filename = xml do tFile.CopyFromAndSave(ht.HttpResponse.Data) do ht.%Close(), $system.OBJ.Load(xml,"ck") do ##class(%File).Delete(xml)




docker run --rm --name iris-sql -d -p 9091:1972 -p 9092:52773  -e IRIS_PASSWORD=demo -e IRIS_USERNAME=demo intersystemsdc/iris-community


docker run --rm --name iris-ce -d -p 9091:1972 -p 9092:52773 -e IRIS_PASSWORD=demo -e IRIS_USERNAME=demo intersystemsdc/iris-community -a "echo 'zpm \"install webterminal\"' | iriscli"



docker run --rm --name iris-sql -d -p 9092:52773 containers.intersystems.com/intersystems/iris-community:2023.1.0.229.0


docker run --rm --name iris-ce -d -p 9092:52773 containers.intersystems.com/intersystems/iris-community:2023.1.0.229.0