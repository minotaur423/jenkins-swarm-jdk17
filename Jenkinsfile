pipeline {
  agent { label 'jdk17' }
  options {
    disableConcurrentBuilds()
    buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '30', numToKeepStr: '10')
  }
  environment {
    project = 'jenkins-swarm-jdk17-buildah'
    tag = 'default'
    commitNum = 'default'
  }
  stages{
    stage('Preparation') {
      steps {
        echo "STARTED:\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\n(${env.BUILD_URL})"
        checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-creds', url: 'https://github.com/minotaur423/jenkins-swarm-jdk17.git']])
        script {
          commitNum = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          if(env.BRANCH_NAME.contains('/')) {
            tag = sh(script: "echo ${BRANCH_NAME} |awk -F '/' '{print \$2}'", returnStdout: true).trim()
          } else {
            tag = env.BRANCH_NAME
          }
        }
      }
    }
    stage('Build Image') {
      steps {
          timeout(10) {
            withCredentials([usernamePassword(credentialsId: 'docker_cred', passwordVariable: 'ARTIFACTORY_DOCKER_PWD', usernameVariable: 'ARTIFACTORY_DOCKER_USER')]) {
              sh 'echo ${ARTIFACTORY_DOCKER_PWD} | buildah login -u ${ARTIFACTORY_DOCKER_USER} --password-stdin ${ARTIFACTORY_DOCKER_SERVER}'
            }
            sh "buildah build --pull --no-cache -t ${ARTIFACTORY_DOCKER_SERVER}/docker/${project}:${tag}.${commitNum} ."
            sh "buildah build -t ${ARTIFACTORY_DOCKER_SERVER}/docker/${project}:${tag}-latest ."
          }
      }
    }
    stage('Push Image') {
      steps {
          sh "buildah push ${ARTIFACTORY_DOCKER_SERVER}/docker/${project}:${tag}.${commitNum}"
          sh "buildah push ${ARTIFACTORY_DOCKER_SERVER}/docker/${project}:${tag}-latest"
      }
    }
  }
  post {
    always {
      script {
        tag = "${tag}"
        sh "buildah logout"
      }
    }
    success {
      script {
        latestMessage = "\n---also tagged with 'latest'"
      }
      echo "SUCCESSFUL\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\nDocker Image: '${tag}'${latestMessage}\n(${env.BUILD_URL})"
    }
    failure {
      echo "FAILED\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\n(${env.BUILD_URL})"
    }
  }
}
