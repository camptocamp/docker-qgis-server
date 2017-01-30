#!groovy

properties([
  //rebuild every nights
  pipelineTriggers([cron('H H(0-8) * * *')])
])

IMAGE_NAME = 'camptocamp/qgis-server'

if (env.BRANCH_NAME == 'master') {
  finalTag = 'latest'
} else {
  finalTag = env.BRANCH_NAME
}

lock('docker-qgis-server_tag_' + finalTag) {
  node('docker') {
    try {
      // make sure we don't mess with another build by using latest on both
      env.DOCKER_TAG = env.BUILD_TAG

      stage('Update docker') {
        checkout scm
        sh 'make pull'
      }
      stage('Build') {
        checkout scm
        sh 'make -j3 clean build'
      }
      stage('Test') {
        checkout scm
        try {
          lock("acceptance-${env.NODE_NAME}") {
            sh 'make -j3 acceptance-quick'  //quick because we don't want to rebuild the image
          }
        } finally {
          junit keepLongStdio: true, testResults: 'acceptance_tests/junitxml/*.xml'
        }
      }

      //compute the list of tags we are going to push (old branch => only one)
      tags = [finalTag]

      stage("Publish ${tags}") {
        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub',
                        usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
          //login in docker hub
          sh 'docker login -u "$USERNAME" -p "$PASSWORD"'
          try {
            for (String tag: tags) {
              //give the final tag to the image
              sh "docker tag ${IMAGE_NAME}:${env.DOCKER_TAG} ${IMAGE_NAME}:${tag}"
              //push it
              docker.image("${IMAGE_NAME}:${tag}").push()
            }
          } finally {
            //logout from docker hub
            sh 'rm -rf ~/.docker*'
          }
        }
      }
    } catch(err) {
      // send emails in case of error
      currentBuild.result = "FAILURE"
      throw err
    } finally {
      stage("Emails") {
        step([$class                  : 'Mailer',
              notifyEveryUnstableBuild: true,
              sendToIndividuals       : true,
              recipients              : emailextrecipients([[$class: 'CulpritsRecipientProvider'],
                                                            [$class: 'DevelopersRecipientProvider'],
                                                            [$class: 'RequesterRecipientProvider']])])
      }
    }
  }
}
