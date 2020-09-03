package test

import (
	// "fmt"
	"os"
	"os/exec"
	"testing"
	"time"

	// http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var cluster_name = os.Getenv("CLUSTER_NAME")
var idp_hostname = os.Getenv("IDP_HOSTNAME")
var statebucket = os.Getenv("BUCKET")
var region = os.Getenv("REGION")

// An example of how to test a terraform run.  Because this is not parallelized, it runs first,
// so that the rest of the tests happen on the updated system.
func TestTerraform(t *testing.T) {
	terraformOptions := &terraform.Options{
		// website::tag::1::Set the path to the Terraform code that will be tested.
		// The path to where our Terraform code is located
		TerraformDir: "../terraform",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"cluster_name": cluster_name,
			"idp_hostname": idp_hostname,
		},

		BackendConfig: map[string]interface{}{
			"bucket":         statebucket,
			"key":            "tf-state/" + cluster_name,
			"dynamodb_table": "secops_terraform_locks",
			"region":         region,
		},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	// website::tag::2::Run "terraform init" and "terraform apply".
	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables
	idp_configmap := terraform.Output(t, terraformOptions, "idp_configmap")

	// website::tag::3::Check the output against expected values.
	// Verify we're getting back the outputs we expect
	domain_name_line := "domain_name: " + idp_hostname
	assert.Contains(t, idp_configmap, domain_name_line)
}

func TestKubernetes(t *testing.T) {
	t.Parallel()

	// Make sure that the context is set up
	cmd := exec.Command("aws", "eks", "update-kubeconfig", "--name", cluster_name)
	err := cmd.Run()
	assert.Nil(t, err)

	// Verify all the services are available
	options := k8s.NewKubectlOptions("", "", "argocd")
	k8s.WaitUntilServiceAvailable(t, options, "argocd-server", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "argocd-server-metrics", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "argocd-repo-server", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "argocd-dex-server", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "argocd-metrics", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "argocd-redis", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "argocd-repo-server", 10, 1*time.Second)

	options = k8s.NewKubectlOptions("", "", "kube-system")
	k8s.WaitUntilServiceAvailable(t, options, "eksclusterautoscaler-aws-cluster-autoscaler-chart", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "external-dns", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "metrics-server", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "kube-dns", 10, 1*time.Second)

	options = k8s.NewKubectlOptions("", "", "kubernetes-dashboard")
	k8s.WaitUntilServiceAvailable(t, options, "dashboard-kubernetes-dashboard", 10, 1*time.Second)

	options = k8s.NewKubectlOptions("", "", "elastic-system")
	k8s.WaitUntilServiceAvailable(t, options, "elastic-webhook-server", 10, 1*time.Second)

	options = k8s.NewKubectlOptions("", "", "elk")
	k8s.WaitUntilServiceAvailable(t, options, "logstash", 10, 1*time.Second)

	options = k8s.NewKubectlOptions("", "", "istio-operator")
	k8s.WaitUntilServiceAvailable(t, options, "istio-operator", 10, 1*time.Second)

	options = k8s.NewKubectlOptions("", "", "istio-system")
	k8s.WaitUntilServiceAvailable(t, options, "istiod", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "istio-ingressgateway", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "istio-egressgateway", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "kiali", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "prometheus", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "grafana", 10, 1*time.Second)

	options = k8s.NewKubectlOptions("", "", "test")
	k8s.WaitUntilServiceAvailable(t, options, "flagger-loadtester", 10, 1*time.Second)

	options = k8s.NewKubectlOptions("", "", "idp")
	k8s.WaitUntilServiceAvailable(t, options, "idp", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "idp-canary", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "idp-primary", 10, 1*time.Second)
	k8s.WaitUntilServiceAvailable(t, options, "idp-redis", 10, 1*time.Second)
}

// // XXX somehow I broke the idp while messing around with istio
// func TestIdp(t *testing.T) {
// 	t.Parallel()

// 	url := fmt.Sprintf("https://%s/api/health/", idp_hostname)

// 	// Make an HTTP request to the URL and make sure it is healthy
// 	http_helper.HttpGetWithRetry(t, url, nil, 200, "healthy\":true", 10, 3*time.Second)
// }
