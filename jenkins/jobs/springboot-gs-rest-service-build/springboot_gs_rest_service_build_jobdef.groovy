def repo = 'https://github.com/mattandes/springboot-gs-rest-service.git'

pipelineJob('springboot-gs-rest-service-build') {
  triggers {
    scm('H/1 * * * *')
  }
  description("SpringBoot GS Rest Service Build")
  displayName("SpringBoot GS Rest Service Build")

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