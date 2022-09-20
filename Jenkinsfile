def project = "https://gitlab.com/oneicc/ifsm---field-manager.git"
def devops_project = "https://gitlab.com/oneicc/icc.infrastructure.git"
def env = "production-imv"
def namespace = "dms-app"
properties([
        parameters([
                gitParameter(branchFilter: 'origin/(.*)', defaultValue: 'master', name: 'BRANCH', type: 'PT_BRANCH', listSize: "10", useRepository: "${project}", quickFilterEnabled: true),
                 [$class: 'ChoiceParameter',
                 choiceType: 'PT_MULTI_SELECT',
                 description: 'Select Type for run',
                 filterLength: 1,
                 filterable: false,
                 name: 'Service',
                 randomName: 'choice-parameter-563132144557478619',
                 script: [
                         $class: 'GroovyScript',
                         // fallbackScript: [
                         //         classpath: [],
                         //         sandbox: false,
                         //         script:
                         //                 'return[\'Could not get Type\']'
                         // ],
                         script: [
                                 classpath: [],
                                 sandbox: false,
                                 script:
                                         'return["backend", "frontend"]'
                         ]
                 ]
                ]
        ])
])
pipeline {
  environment {
    registry = "https://registry-1.docker.io/v2/"
    registryCredential = 'dockerhub'
  }
    agent none
    stages {
        stage('get config fe'){
        agent { label "worker"}
          steps{
            script {
              dir("${env}"){
                echo "===================== GET CONFIG FE ====================="
                sh "./get_config_fe.sh ${env}"
              }
            }
          }
        }
        stage('clone code') {
        agent { label "worker"}
            steps {
              script {
                currentBuild.displayName = "${params.Service}-${BUILD_NUMBER}-${params.BRANCH}"
                dir("${env}/app-${params.Service}/src-branch-build"){
                  echo "===================== CLONE CODE ====================="
                  cloneCode(project, params.BRANCH)
                  echo "===================== check current dir ====================="
                  sh 'echo $PWD'
                  echo "===================== check folder/file ====================="
                  sh 'ls -lh '
                  switch( params.Service.trim() ) {
                    case "backend":
                      echo "===================== build backend ====================="
                      bebuild("SRC/Backend","SRC/Applications/DebugRunning.Application","v10.24.1")
                      break;
                    case "frontend":
                      echo "===================== build frontend ====================="
                      febuild(env,"SRC/Frontend/fsm","v10.24.1")
                      break;
                  }
                }
              }
            }
        }
        stage('build') {
        agent { label "worker"}
            steps {
              script {
                currentBuild.displayName = "${params.Service}-${BUILD_NUMBER}-${params.BRANCH}"
                dir("${env}/app-${params.Service}"){
                  echo "===================== BUILD DOCKER IMAGE ====================="
                  dockerbuild(env, params.Service, BUILD_NUMBER)
                }
              }
            }
        }
        stage("kubectl apply image") {
        agent { label "master" }
            steps {
              script{
                  echo "===================== APPLY / DEPLOY - NEW IMAGE  ====================="
                  // if (params.Service.trim() == "backend") {
                  deploy(env, params.Service, BUILD_NUMBER)
                  // }
              }
              timeout(time: 120, unit: 'SECONDS') {
                echo "===================== WAITING UNTIL SERVICE LISTEN PORT SUCCESS  ====================="
                rollout(env,namespace, params.Service)
              }
            }
        }
    }
    post {
        failure {
            node('master') {
                echo 'failed'
                wrap([$class: 'BuildUser']) {
                    sendTelegram("ON-STAGING-IMV | <i>${params.Service}-service</i> | ${JOB_NAME} | BRANCH ${params.BRANCH} | <b>FAILED</b> by ${BUILD_USER} | ${BUILD_URL}")
                }
            }
        }
        aborted {
            node('master') {
                echo 'aborted'
                wrap([$class: 'BuildUser']) {
                    sendTelegram("ON-STAGING-IMV | <i>${params.Service}-service</i> | ${JOB_NAME} | BRANCH ${params.BRANCH} | <b>ABORTED OR TIMEOUT</b> by ${BUILD_USER} | ${BUILD_URL}")
                }
            }
        }
        success {
            node('master') {
                echo 'success'
                wrap([$class: 'BuildUser']) {
                    sendTelegram("ON-STAGING-IMV | <i>${params.Service}-service</i> | ${JOB_NAME} | BRANCH ${params.BRANCH} | <b>SUCCESS</b> by ${BUILD_USER} | ${BUILD_URL}")
                }
            }
        }
    }
}
def onlydotnetbuild(_pathsource,_pathartifact) {
  sh " cd ${_pathsource} \
      && dotnet restore \
      && dotnet build *.sln --configuration Release \
      && cd ${_pathartifact} \
      && dotnet publish -c Release -o out"
}

def bebuild(_pathsource,_pathartifact,_versionnode) {
  sh " cd ${_pathsource} \
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
      && cp -r Modulars out/"
}

def febuild(_env,_pathsource,_versionnode) {
  sh " cd ${_pathsource} \
      && sudo n ${_versionnode} \
      && node --version \
      && npm --version \
      && yarn --version \
      && gulp --version \
      && rm -rf src/app-configs/app-config.json src/app-configs/app-config.scss \
      && rsync -av /tmp/${_env}/app-config.json src/app-configs/ \
      && rsync -av /tmp/${_env}/app-config.scss src/app-configs/ \
      && cat src/app-configs/app-config.json \
      && cat src/app-configs/app-config.scss \
      && npm i \
      && npm run build-prod"
}

def dockerbuild(_env, _service, _buildnumber) {
  // sh "cp /tmp/*.json ."
   app = docker.build("registry.oneicc.vn/dms/${_env}-${_service}-service:${_buildnumber}", "-f Dockerfile .")
  // sh "docker build -f SRC/Infratructure/app-${_service}/Dockerfile -t giangaws/${_service}-service:${_buildnumber} ."
  // sh "docker login --username giangaws --password && docker push giangaws/${_service}-service:${_buildnumber}"
  // docker.withRegistry('https://registry-1.docker.io/v2/', 'dockerhub') {
  docker.withRegistry('https://registry.oneicc.vn', 'harbor') {
    app.push("${_buildnumber}")
    // app.push("latest")
  }
}

def build(_env, _service, _buildnumber) {
  sh "cp /tmp/*.json ."
  sh "cp /tmp/*.scss ."
  app = docker.build("registry.oneicc.vn/dms/${_env}-${_service}-service:${_buildnumber}", "-f ${_env}/app-${_service}/Dockerfile .")
  // sh "docker build -f SRC/Infratructure/app-${_service}/Dockerfile -t giangaws/${_service}-service:${_buildnumber} ."
  // sh "docker login --username giangaws --password && docker push giangaws/${_service}-service:${_buildnumber}"
  // docker.withRegistry('https://registry-1.docker.io/v2/', 'dockerhub') {
  docker.withRegistry('https://registry.oneicc.vn', 'harbor') {
    app.push("${_buildnumber}")
    // app.push("latest")
  }
}

def deploy(_env, _service, _buildnumber) {
    sh  "cd ${_env}/app-${_service} \
        && ls -l \
        && sed -i \"s/BUILD_NUMBER/${_buildnumber}/g\" deployment.yaml \
        && kubectl apply -f deployment.yaml --kubeconfig ~/.kube/config --record"

}
def rollout(_env,_namespace, _service) {
  sh  "kubectl rollout status deployment ${_env}-${_service}-service -n ${_namespace}"
}
def cloneCode(repo, tag) {
    checkout([$class: 'GitSCM',
        branches: [[name: "${tag}"]],
        doGenerateSubmoduleConfigurations: false,
        extensions: [],
        gitTool: 'Default',
        submoduleCfg: [],
        userRemoteConfigs: [[credentialsId: 'gitlab', url: "${repo}"]]
    ])
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
