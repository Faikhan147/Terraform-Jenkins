def plugins = [
    "git-parameter",          // Git Parameter
    "github-auth",            // GitHub Authentication
    "pipeline-github",        // Pipeline: GitHub
    "generic-webhook-trigger", // Generic Webhook Trigger
    "git-push",               // Git Push
    "sonar",                  // SonarQube Scanner
    "slack"                   // Slack Notification
]

def jenkinsInstance = Jenkins.getInstance()
def pluginManager = jenkinsInstance.getPluginManager()
def updateCenter = jenkinsInstance.getUpdateCenter()

plugins.each {
    if (!pluginManager.getPlugin(it)) {
        def plugin = updateCenter.getPlugin(it)
        if (plugin) {
            plugin.deploy()
        }
    }
}
jenkinsInstance.save()
