def dev_repo_imv = "https://github.com/Saaspiens/merchandising-plarform.git"
def devops_project = "https://github.com/Saaspiens/ICC-IMV-DEV.git"
def namespace = "imv-dev"
properties([
        parameters([
                string(defaultValue: 'Merchandising', name: 'TAG'),
                 [$class: 'ChoiceParameter',
                 choiceType: 'PT_SINGLE_SELECT',
                 description: 'Select Type for run',
                 filterLength: 1,
                 filterable: false,
                 name: 'Service',
                 randomName: 'choice-parameter-563132144557478619',
                 script: [
                         $class: 'GroovyScript',
                         script: [
                                 classpath: [],
                                 sandbox: false,
                                 script:
                                         'return["backend","frontend"]'
                         ]
                 ]
                ]
        ])
])
pipeline {
  agent any
  environment {
    registry = "https://registry-1.docker.io/v2/"
    registryCredential = 'dockerhub'
    imageId = "registry.1retail-dev.asia/imv-dev/${params.Service}-service:$BUILD_NUMBER"
    docker_registry = 'https://registry.1retail-dev.asia'
    docker_creds = credentials('harbor')
  }
  stages {
    stage('Clone & Build Code') {
          steps {
            script {
            currentBuild.displayName = "${params.Service}-${BUILD_NUMBER}-${params.TAG}"
              switch( params.Service.trim() ) {
                    case "backend":
                          clonecode(dev_repo_imv)
                          sh "ls -lh"
                          getconfigbe("SRC/Applications/DebugRunning.Application")
                          bebuild("SRC/Applications/DebugRunning.Application", "v16.14.2")
                          //efmigration("tenant")
                          break;
                    case "frontend":
                          clonecode(dev_repo_imv)
                          sh "ls -lh"
                          getconfigfe("SRC/Frontend/fsm")
                          febuild("SRC/Frontend/fsm", "v12.18.0")
                          //efmigration("user")
                          break;
              }
           }
         } 
    }
    stage('Build Docker') {
            steps {
              script {     
                            
                  currentBuild.displayName = "${params.Service}-${BUILD_NUMBER}-${params.TAG}"
                  echo "===================== BUILD DOCKER IMAGE ====================="
                  sh "sudo n 16.14.2"
                  sh "node --version"
                  sh "cp ${params.Service}/* src-build/"
                  dir ("src-build"){
                  sh "ls -lh"
                  sh "pwd"
                  //sh "ls -la src"
                  sh "docker login $docker_registry --username $docker_creds_USR --password $docker_creds_PSW"
                  sh "docker build -t $imageId ."
                  sh "docker tag $imageId $imageId"
                  sh "docker push $imageId"
                  sh "docker logout"
                  sh "docker rmi -f $imageId"
                  //sh "docker rmi ${imageId}"
                  }
                }
            }
      } 
    stage('Deploy') {
          steps {
            checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, gitTool: 'NONE', extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'Github', url: devops_project]]])
            script{
                  sh "ls -la"
                  echo "===================== Deploy - ${params.Service} ====================="
                  sh "cd ${params.Service} \
                      ls -l \
                      && sed -i \"s/BUILD_NUMBER/${BUILD_NUMBER}/g\" Deployment.yaml \
                      && kubectl apply -f Deployment.yaml --kubeconfig ~/.kube/config --record"
              }
              timeout(time: 3000, unit: 'SECONDS') {
                echo "===================== WAITING UNTIL SERVICE LISTEN PORT SUCCESS  ====================="
                sh  "kubectl rollout status deployment ${params.Service}-service -n $namespace"
              }
          }
    }
    stage('Clean') {
          steps {
            sh "docker system prune -f"
          }
    }
  }
  
  post {
    always {
       cleanWs()
    }
        // failure {
        //         echo 'failed'
        //         wrap([$class: 'BuildUser']) {
        //             sendTelegram("ON-COMATIC-DEV | <i>${params.Service}</i> | ${JOB_NAME} | TAG ${params.TAG} | <b>FAILED</b> by ${BUILD_USER} | ${BUILD_URL}")
        //         }
        // }
        // aborted {
        //         echo 'aborted'
        //         wrap([$class: 'BuildUser']) {
        //             sendTelegram("ON-COMATIC-DEV | <i>${params.Service}</i> | ${JOB_NAME} | TAG ${params.TAG} | <b>ABORTED OR TIMEOUT</b> by ${BUILD_USER} | ${BUILD_URL}")
        //         }
        // }
        // success {
        //         echo 'success'
        //         wrap([$class: 'BuildUser']) {
        //             sendTelegram("ON-COMATIC-DEV | <i>${params.Service}</i> | ${JOB_NAME} | TAG ${params.TAG} | <b>SUCCESS</b> by ${BUILD_USER} | ${BUILD_URL}")
        //         }
        // }
  }
}
def sendTelegram(message) {
    def encodedMessage = URLEncoder.encode(message, "UTF-8")

    withCredentials([string(credentialsId: 'telegramToken', variable: 'TOKEN'),
    string(credentialsId: 'telegramChatId', variable: 'CHAT_ID')]) {

        response = httpRequest (consoleLogResponseBody: true,
                contentType: 'APPLICATION_JSON',
                httpMode: 'GET',
                url: "https://api.telegram.org/bot${TOKEN}/sendMessage?text=${encodedMessage}&chat_id=${CHAT_ID}&disable_web_page_preview=true&parse_mode=html",
                validResponseCodes: '200')
        return response
    }
}
def clonecode(repo){
  withCredentials([gitUsernamePassword(credentialsId: 'Github', gitToolName: 'git-tool')]) {
  sh "git clone --branch main --recursive ${repo} src-build/"
}
}
def bebuild(_pathartifact,_versionnode) {
      script {
            sh "cd src-build \
                  && cd SRC \
                  && cd Backend \
                  && dotnet restore \
                  && dotnet build *.sln --configuration Release \
                  && cd ${_pathartifact} \
                  && dotnet publish -c Release -o out \
                  && sudo n ${_versionnode} \
                  && node --version \
                  && npm --version \
                  && yarn --version \
                  && gulp --version \
                  && sed -i \"s/Debug/Release/g\" gulpfile.js \
                  && npm i -f \
                  && gulp copy-modules \
                  && cp appsettings.json out/ \
                  && mkdir out/config \
                  && cp appsettings.json out/config \
                  && cp -r Modulars out/ "
            sh "pwd"
            sh "ls -la src-build/SRC/Backend/${_pathartifact}/out"
            sh "cat src-build/SRC/Backend/${_pathartifact}/out/config/appsettings.json"
            sh "cp -r src-build/SRC/Backend/${_pathartifact}/out $WORKSPACE/src-build/"
      }
}
def febuild(_pathartifact,_versionnode) {
      script {
            sh "cat src-build/${_pathartifact}/src/app-configs/app-config.json"
            sh "cat src-build/${_pathartifact}/src/app-configs/app-config.scss"
            sh "cat src-build/${_pathartifact}/src/app-configs/app-config.development.json"
            sh "cd src-build/${_pathartifact} \
                  && sudo n ${_versionnode} \
                  && node --version \
                  && npm --version \
                  && yarn --version \
                  && gulp --version \
                  && pwd \
                  && ls -la \
                  && npm cache clean --force \
                  && npm install \
                  && npm i -f \
                  && ls -la \
                  && npm run build-prod \
                  && npm run test \
                  && npm run lint"
            sh "ls -la src-build/SRC/Frontend/fsm/dist/"
            sh "cp -r src-build/SRC/Frontend/fsm/dist/ $WORKSPACE/src-build/"
      }
}
def getconfigbe(_pathartifact){
      script {
            sh "rm -rf src-build/SRC/Backend/${_pathartifact}/appsettings.json"
            sh "chmod +x $WORKSPACE/${params.Service}/get-config-be.sh"
            sh "$WORKSPACE/${params.Service}/get-config-be.sh"
            sh "ls -la"
      }
}
def getconfigfe(_pathartifact){
      script {
            sh "rm -f src-build/${_pathartifact}/src/app-configs/*"
            sh "chmod +x $WORKSPACE/${params.Service}/get-config-fe.sh"
            sh "$WORKSPACE/${params.Service}/get-config-fe.sh"
            sh "ls -la"
      }
}

