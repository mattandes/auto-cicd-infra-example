def repo = "git@${GITLAB_HOST}:examples/springboot-gs-rest-service.git"
def gitCredential = "gitlab-root-private-key"
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
          remote { 
            url(repo)
            credentials(gitCredential)
          }
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