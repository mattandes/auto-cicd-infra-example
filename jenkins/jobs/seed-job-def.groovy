def jobName = 'seed-job'
def jobDisplayName = 'Jenkins Seed Job'
def jobDescription = 'This job will load all of the other jobs definitions from the repository.'
def gitUrl = 'https://github.com/mattandes/auto-cicd-infra-example.git'
def gitBranch = 'master'
def dslScriptsTargets = 'jenkins/jobs/**/jobdef.groovy'

job(jobName) {
	description(jobDescription)
	displayName(jobDisplayName)
	keepDependencies(false)
	disabled(false)
    triggers {
		scm("H/1 * * * *") {
			ignorePostCommitHooks(false)
		}
	}
	concurrentBuild(false)
    scm {
        git {
          remote { 
            url(gitUrl)
          }
          branch(gitBranch)
          extensions { }  // required as otherwise it may try to tag the repo, which you may not want
        }
    }
	steps {
		configure { node ->
            node / builders / 'javaposse.jobdsl.plugin.ExecuteDslScripts' / targets(dslScriptsTargets)
            node / builders / 'javaposse.jobdsl.plugin.ExecuteDslScripts' / usingScriptText('false')
            node / builders / 'javaposse.jobdsl.plugin.ExecuteDslScripts' / sandbox('false')
            node / builders / 'javaposse.jobdsl.plugin.ExecuteDslScripts' / ignoreExisting('false')
            node / builders / 'javaposse.jobdsl.plugin.ExecuteDslScripts' / ignoreMissingFiles('true')
            node / builders / 'javaposse.jobdsl.plugin.ExecuteDslScripts' / failOnMissingPlugin('false')
            node / builders / 'javaposse.jobdsl.plugin.ExecuteDslScripts' / unstableOnDeprecation('false')
	    	node / builders / 'javaposse.jobdsl.plugin.ExecuteDslScripts' / removedJobAction('DISABLE')
		    node / builders / 'javaposse.jobdsl.plugin.ExecuteDslScripts' / removedViewAction('DELETE')
            node / builders / 'javaposse.jobdsl.plugin.ExecuteDslScripts' / removedConfigFilesAction('IGNORE')
		    node / builders / 'javaposse.jobdsl.plugin.ExecuteDslScripts' / lookupStrategy('JENKINS_ROOT')
		}
	}
}
