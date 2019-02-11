def repo = "${GITLAB_URL}/examples/springboot-gs-rest-service.git"
def buildsToKeep = 15

pipelineJob('springboot-gs-rest-service-build') {
  triggers {
    scm('H/1 * * * *')
  }
  description("SpringBoot GS Rest Service Build")
  displayName("SpringBoot GS Rest Service Build")
  logRotator {
    numToKeep(buildsToKeep)
  }
  definition {
    cpsScm {
      scm {
        git {
          remote { url(repo) }
          branches('master')
          scriptPath('Jenkinsfile')
          extensions { 
            cleanBeforeCheckout()
          }
        }
      }
    }
  }
}