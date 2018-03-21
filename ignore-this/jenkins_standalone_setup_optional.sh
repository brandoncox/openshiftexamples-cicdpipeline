# DO THIS FIRST
# Note that using this method you currently (in 3.7) will also need to turn off
# autoprovisioning in the master-config.yaml
#
# jenkinsPipelineConfig:
#    autoProvisionEnabled: false

# Create project and create Jenkins server
oc new-project cicd --display-name="CI/CD"
oc new-app jenkins-ephemeral
#oc new-app jenkins-persistent
oc adm policy add-cluster-role-to-user edit system:serviceaccount:cicd:jenkins

# Create pipeline demo projects
oc new-project pipeline-app --display-name="Sandbox for Pipeline Demo"
oc new-project pipeline-app-staging --display-name="Staging for Pipeline Demo"
oc new-project pipeline-app-prod --display-name="Production for Pipeline Demo"

# Switch to the dev project and create the pipeline build from a template
oc project pipeline-app
oc create -f https://raw.githubusercontent.com/dudash/openshiftexamples-cicdpipeline/master/pipeline_instant_template_embeded.yaml
#oc create -f https://raw.githubusercontent.com/dudash/openshiftexamples-cicdpipeline/master/ignore-this/pipeline_instant_template_external.yaml

# Give the other related projects the role to pull images from other projects
oc policy add-role-to-group system:image-puller system:serviceaccounts:pipeline-app -n pipeline-app-staging
oc policy add-role-to-group system:image-puller system:serviceaccounts:pipeline-app-staging -n pipeline-app-prod

# DO THIS LAST
# And now you need to inform the Jenkins sync plugin which 
# namespaces to watch for pipeline builds.  
# 1) Goto the Jenkins webconsole and "Manage Jenkins"
# 2) Scroll down to "OpenShift Jenkins Sync"
# 3) In the namespaces text edit add "pipeline-app"
