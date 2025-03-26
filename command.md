---
page_title: terraform state commands reference
description: The `terraform state` group of commands enable advanced Terraform state management.
---

# `terraform state` commands

The `terraform state` commands enable advanced state management.  

## Introduction

You can use the `terraform state` commands to modify the [Terraform state](/terraform/language/state) instead modifying the state directly.

## Usage

Usage: `terraform state <subcommand> [options] [args]`

Refer to the following subcommands for additional information:

- [`terraform state list`](/terraform/cli/commands/state/list)
- [`terraform state mv`](/terraform/cli/commands/state/mv)
- [`terraform state pull`](/terraform/cli/commands/state/pull)
- [`terraform state replace-provider`](/terraform/cli/commands/state/replace-provider)
- [`terraform state rm`](/terraform/cli/commands/state/rm)
- [`terraform state show`](/terraform/cli/commands/state/show)

## Remote State

The Terraform state subcommands all work with remote state just as if it
was local state. Reads and writes may take longer than normal as each read
and each write do a full network roundtrip. Otherwise, backups are still
written to disk and the CLI usage is the same as if it were local state.

## Backups

All `terraform state` subcommands that modify the state write backup
files. The path of these backup file can be controlled with `-backup`.

Subcommands that are read-only (such as [list](/terraform/cli/commands/state/list))
do not write any backup files since they aren't modifying the state.

Note that backups for state modification _can not be disabled_. Due to
the sensitivity of the state file, Terraform forces every state modification
command to write a backup file. You'll have to remove these files manually
if you don't want to keep them around.

## Command-Line Friendly

The output and command-line structure of the state subcommands is
designed to be usable with Unix command-line tools such as grep, awk,
and similar PowerShell commands.

For advanced filtering and modification, we recommend piping Terraform
state subcommands together with other command line tools.


---
page_title: terraform state show command reference
description: >-
  The `terraform state show` command shows the attributes of a single
  resource in the Terraform state.
---

# `terraform state show` command

The `terraform state show` command shows the attributes of a
single resource in the
[Terraform state](/terraform/language/state).

## Usage

Usage: `terraform state show [options] ADDRESS`

The command will show the attributes of a single resource in the
state file that matches the given address.

This command requires an address that points to a single resource in the
state. Addresses are
in [resource addressing format](/terraform/cli/state/resource-addressing).

The command-line flags are all optional. The following flags are available:

* `-state=path` - Path to the state file. Defaults to "terraform.tfstate".
  Ignored when [remote state](/terraform/language/state/remote) is used.

The output of `terraform state show` is intended for human consumption, not
programmatic consumption. To extract state data for use in other software, use
[`terraform show -json`](/terraform/cli/commands/show#json-output) and decode the result
using the documented structure.

## Example: Show a Resource

The example below shows a `packet_device` resource named `worker`:

```
$ terraform state show 'packet_device.worker'
# packet_device.worker:
resource "packet_device" "worker" {
    billing_cycle = "hourly"
    created       = "2015-12-17T00:06:56Z"
    facility      = "ewr1"
    hostname      = "prod-xyz01"
    id            = "6015bg2b-b8c4-4925-aad2-f0671d5d3b13"
    locked        = false
}
```

## Example: Show a Module Resource

The example below shows a `packet_device` resource named `worker` inside a module named `foo`:

```shell
$ terraform state show 'module.foo.packet_device.worker'
```

## Example: Show a Resource configured with count

The example below shows the first instance of a `packet_device` resource named `worker` configured with
[`count`](/terraform/language/meta-arguments/count):

```shell
$ terraform state show 'packet_device.worker[0]'
```

## Example: Show a Resource configured with for_each

The following example shows the `"example"` instance of a `packet_device` resource named `worker` configured with the [`for_each`](/terraform/language/meta-arguments/for_each) meta-argument. You must place the resource name in single quotes when it contains special characters like double quotes.

Linux, Mac OS, and UNIX:

```shell
$ terraform state show 'packet_device.worker["example"]'
```

PowerShell:

```shell
$ terraform state show 'packet_device.worker[\"example\"]'
```

Windows `cmd.exe`:

```shell
$ terraform state show packet_device.worker[\"example\"]
```



---
page_title: Import existing resources
description: Learn now to use the `terraform import` command to import existing infrastructure resources.
---

# Import existing resources

This topic describes how to use the `terraform import` command to import existing infrastructure resources so that you can manage them as code.

> **Hands-on:** Try the [Import Terraform Configuration](/terraform/tutorials/state/state-import?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorial.

## Overview

Use the `terraform import` command to import existing infrastructure to Terraform state. The `terraform import` command can only import one resource at a time. It cannot simultaneously import an entire collection of resources, such as an AWS VPC.

Complete the following steps to import resources:

1. Add the resource you want to manage with Terraform to your Terraform configuration.
1. Run the `terraform import` command.


~> Warning: Terraform expects that each remote object it is managing will be
bound to only one resource address, which is normally guaranteed by Terraform
itself having created all objects. If you import existing objects into Terraform,
be careful to import each remote object to only one Terraform resource address.
If you import the same object multiple times, Terraform may exhibit unwanted
behavior. For more information on this assumption, see
[the State section](/terraform/language/state).

## Add the resource to your configuration

Write a resource block for the resource you want to import in your configuration. 
Provide a name for the resource, which is a unique ID that you can use to reference the resource elsewhere in the configuration.

In the following example, the imported resource is an AWS instance named `example`:

```hcl
resource "aws_instance" "example" {
  # ...instance configuration...
}
```

You do not have to complete the body of the resource block. Instead, you can finish defining arguments after the instance is imported.

## Run the `terraform import` command

Run `terraform import` to attach an existing instance to the
resource configuration:

```shell
$ terraform import aws_instance.example i-abcd1234
```

This command locates the AWS EC2 instance with ID `i-abcd1234`. Then it attaches
the existing settings of the instance, as described by the EC2 API, to the
name `aws_instance.example` of a module. In this example, the module path
implies that the root module is used. Finally, the mapping is saved in the
Terraform state.

It is also possible to import to resources in child modules, using their paths,
and to single instances of a resource with `count` or `for_each` set. See
[_Resource Addressing_](/terraform/cli/state/resource-addressing) for more
details on how to specify a target resource.

The syntax of the given ID is dependent on the resource type being imported.
For example, AWS instances use an opaque ID issued by the EC2 API, but
AWS Route53 Zones use the domain name itself. Consult the documentation for
each importable resource for details on what form of ID is required.

As a result of the above command, the resource is recorded in the state file.
You can now run `terraform plan` to see how the configuration compares to
the imported resource, and make any adjustments to the configuration to
align with the current (or desired) state of the imported object.

## Complex Imports

The above import is considered a "simple import": one resource is imported
into the state file. An import may also result in a "complex import" where
multiple resources are imported. For example, an AWS network ACL imports
an `aws_network_acl` but also one `aws_network_acl_rule` for each rule.

In this scenario, the secondary resources will not already exist in
the configuration, so it is necessary to consult the import output and create
a `resource` block in the configuration for each secondary resource. If this is
not done, Terraform will plan to destroy the imported objects on the next run.

If you want to rename or otherwise move the imported resources, the
[state management commands](/terraform/cli/commands/state) can be used.




---
page_title: Initialize the Terraform working directory
description: >-
  Learn how to initialize the working directory with the terraform init command, which installs plugins and modules defined in the configuration and retrieves state data.  
---

# Initialize the Working Directory

Terraform expects to be invoked from a working directory that contains
configuration files written in
[the Terraform language](/terraform/language). Terraform uses
configuration content from this directory, and also uses the directory to store
settings, cached plugins and modules, and sometimes state data.

A working directory must be initialized before Terraform can perform any
operations in it (like provisioning infrastructure or modifying state).

## Working Directory Contents

A Terraform working directory typically contains:

- A Terraform configuration describing resources Terraform should manage. This
  configuration is expected to change over time.
- A hidden `.terraform` directory, which Terraform uses to manage cached
  provider plugins and modules, record which
  [workspace](/terraform/cli/workspaces) is currently active, and
  record the last known backend configuration in case it needs to migrate state
  on the next run. This directory is automatically managed by Terraform, and is
  created during initialization.
- State data when the configuration uses the default `local` backend. Terraform manages state in a `terraform.tfstate` file when the directory only uses
  the default workspace or a `terraform.tfstate.d` directory when the directory
  uses multiple workspaces.

## Initialization

Run the `terraform init` command to initialize a working directory that contains
a Terraform configuration. After initialization, you will be able to perform
other commands, like `terraform plan` and `terraform apply`.

If you try to run a command that relies on initialization without first
initializing, the command will fail with an error and explain that you need to
run init.

Initialization performs several tasks to prepare a directory, including
accessing state in the configured backend, downloading and installing provider
plugins, and downloading modules. Under some conditions (usually when changing
from one backend to another), it might ask the user for guidance or
confirmation.

For details, see [the `terraform init` command](/terraform/cli/commands/init).

## Reinitialization

Certain types of changes to a Terraform configuration can require
reinitialization before normal operations can continue. This includes changes to
provider requirements, module sources or version constraints, and backend
configurations.

You can reinitialize a directory by running `terraform init` again. In fact, you
can reinitialize at any time; the init command is idempotent, and will have no
effect if no changes are required.

If reinitialization is required, any commands that rely on initialization will
fail with an error and tell you so.

## Reinitializing Only Modules

The `terraform get` command will download modules referenced in the
configuration, but will not perform the other required initialization tasks.
This command is only useful for niche workflows, and most Terraform users can
ignore it in favor of `terraform init`.





---
page_title: Install Terraform using APT packages for Debian and Ubuntu
description: >-
  Learn how to install Terraform using HashiCorp APT packages for Debian and Ubuntu systems.
---

# Install Terraform Using APT Packages for Debian and Ubuntu

The primary distribution packages for Terraform are `.zip` archives containing
single executable files that you can extract anywhere on your system. However,
for easier integration with configuration management tools and other systematic
system configuration strategies, we also offer package repositories for
Debian and Ubuntu systems, which allow you to install Terraform using the
`apt install` command or any other APT frontend.

If you are instead using Red Hat Enterprise Linux, CentOS, or Fedora, you
might prefer to [install Terraform from our Yum repositories](/terraform/cli/install/yum).

-> **Note:** The APT repositories discussed on this page are generic HashiCorp
repositories that contain packages for a variety of different HashiCorp
products, rather than just Terraform. Adding these repositories to your
system will, by default, therefore make several other non-Terraform
packages available for installation. That might then mask some packages that
are available for some HashiCorp products in the main Debian and Ubuntu
package repositories.

## Repository Configuration

Please follow the instructions in the [Official Packaging Guide](https://www.hashicorp.com/official-packaging-guide).

## Supported Architectures

The HashiCorp APT server has packages only for the `amd64`
architecture, which is also sometimes known as `x86_64`.

There are no official packages available for other architectures, such as
`arm64`. If you wish to use Terraform on a non-`amd64` system,
[download a normal release `.zip` file](/terraform/downloads) instead.

## Supported Debian and Ubuntu Releases

The HashiCorp APT server contains release repositories for a variety of
supported distributions, which are outlined in the [Official Packaging Guide](https://www.hashicorp.com/official-packaging-guide).

## Installing a Specific Version of Terraform

The HashiCorp APT repositories contain multiple versions of Terraform, but
because the packages are all named `terraform` it is impossible to install
more than one version at a time, and `apt install` will default to selecting
the latest version.

It's often necessary to match your Terraform version with what a particular
configuration is currently expecting. You can use the following command to
see which versions are currently available in the repository index:

```bash
apt policy terraform
```

If your workflow requires using multiple versions of Terraform at the same
time, for example when working through a gradual upgrade where not all
of your configurations are upgraded yet, we recommend that you use the
official release `.zip` files instead of the APT packages, so you can install
multiple versions at once and then select which to use for each command you
run.

### Terraform 1.4.3 and Later

As of Terraform 1.4.3, all published packages include a revision number by
default, starting with `-1`. This change means that in the case that we need
to publish an updated package for any reason, installers can automatically
retrieve the latest revision. You can learn more about this packaging change
in [the announcement](https://discuss.hashicorp.com/t/linux-packaging-debian-revision-change/42403).

You can install the latest revision for a particular version by including the
version in the `apt install` command, as follows:

```bash
sudo apt install terraform=1.4.4-*
```

### Terraform 1.4.2 and Earlier

Terraform 1.4.2 and earlier did not include a revision number for the first
revision, so you can use the following pattern to install a specific version:

```bash
sudo apt install terraform=1.4.0
```




---
page_title: Terraform workflow for provisioning infrastructure
description: Learn how to use the Terraform CLI to provision infrastructure.
---

# Terraform workflow for provisioning infrastructure 

This topic provides overview information about the Terraform workflow for provisioning infrastructure using the Terraform CLI.

## Workflows

You can use Terraform to create, modify, and destroy infrastructure
resources to match the desired state described in a
[Terraform configuration](/terraform/language). The
Terraform binary includes commands and subcommands for a wide variety of infrastructure lifecycle management
actions, but the following commands provide basic provisioning tasks: 

- `terrafrom plan` 
- `terraform apply`
- `terraform destroy` 

All of these commands require an [initialized](/terraform/cli/init) working directory, and all of them act
only upon the currently selected [workspace](/terraform/cli/workspaces).

### Plan

The `terraform plan` command evaluates a Terraform configuration to determine
the desired state of all the resources it declares, then compares that desired
state to the real infrastructure objects being managed with the current working
directory and workspace. It uses state data to determine which real objects
correspond to which declared resources, and checks the current state of each
resource using the relevant infrastructure provider's API.

Once it has determined the difference between the current state and the desired
state, `terraform plan` presents a description of the changes necessary to
achieve the desired state. It _does not_ perform any actual changes to real
world infrastructure objects; it only presents a plan for making changes.

Plans are usually run to validate configuration changes and confirm that the
resulting actions are as expected. However, `terraform plan` can also save its
plan as a runnable artifact, which `terraform apply` can use to carry out those
exact changes.

For details, see [the `terraform plan` command](/terraform/cli/commands/plan).

### Apply

The `terraform apply` command performs a plan just like `terraform plan` does,
but then actually carries out the planned changes to each resource using the
relevant infrastructure provider's API. It asks for confirmation from the user
before making any changes, unless it was explicitly told to skip approval.

By default, `terraform apply` performs a fresh plan right before applying
changes, and displays the plan to the user when asking for confirmation.
However, it can also accept a plan file produced by `terraform plan` in lieu of
running a new plan. You can use this to reliably perform an exact set of
pre-approved changes, even if the configuration or the state of the real
infrastructure has changed in the minutes since the original plan was created.

For details, see [the `terraform apply` command](/terraform/cli/commands/apply).

### Destroy

The `terraform destroy` command destroys all of the resources being managed by
the current working directory and workspace, using state data to determine which
real world objects correspond to managed resources. Like `terraform apply`, it
asks for confirmation before proceeding.

A destroy behaves exactly like deleting every resource from the configuration
and then running an apply, except that it doesn't require editing the
configuration. This is more convenient if you intend to provision similar
resources at a later date.

For details, see [the `terraform destroy` command](/terraform/cli/commands/destroy).





---
page_title: Inspect Terraform state
description: The `terraform state` group of commands help you inspect Terraform state. Learn how inspecting Terraform state can help you read and update state.
---

# Inspect Terraform State Overview

Terraform includes some commands for reading and updating state without taking
any other actions.

- [The `terraform state list` command](/terraform/cli/commands/state/list)
  shows the resource addresses for every resource Terraform knows about in a
  configuration, optionally filtered by partial resource address.

- [The `terraform state show` command](/terraform/cli/commands/state/show)
  displays detailed state data about one resource.

- [The `terraform refresh` command](/terraform/cli/commands/refresh) updates
  state data to match the real-world condition of the managed resources. This is
  done automatically during plans and applies, but not when interacting with
  state directly.




---
page_title: terraform apply command reference
description: The `terraform apply` command executes the actions proposed in a Terraform plan
  to create, update, or destroy infrastructure.
---

# `terraform apply` command

The `terraform apply` command executes the actions proposed in a Terraform
plan.

> **Hands On:** Try the [Apply Terraform Configuration](/terraform/tutorials/cli/apply?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorial to learn how Terraform applies a configuration, how Terraform recovers from errors during apply, and common ways to use this command.

## Usage

Usage: `terraform apply [options] [plan file]`

### Automatic Plan Mode

When you run `terraform apply` without passing a saved plan file, Terraform automatically creates a new execution plan as if you had run [`terraform plan`](/terraform/cli/commands/plan), prompts you to approve that plan, and takes the indicated actions. You can use all of the [planning modes](/terraform/cli/commands/plan#planning-modes) and
[planning options](/terraform/cli/commands/plan#planning-options) to customize how Terraform will create the plan.

You can pass the `-auto-approve` option to instruct Terraform to apply the plan without asking for confirmation.

!> **Warning:** If you use `-auto-approve`, we recommend making sure that no one can change your infrastructure outside of your Terraform workflow. This minimizes the risk of unpredictable changes and configuration drift.

### Saved Plan Mode

When you pass a [saved plan file](/terraform/cli/commands/plan#out-filename) to `terraform apply`, Terraform takes the actions in the saved plan without prompting you for confirmation. You may want to use this two-step workflow when [running Terraform in automation](/terraform/tutorials/automation/automate-terraform?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS).

Use [`terraform show`](/terraform/cli/commands/show) to inspect a saved plan file before applying it.

When using a saved plan, you cannot specify any additional planning modes or options. These options only affect Terraform's decisions about which
actions to take, and the plan file contains the final results of those
decisions.

### Plan Options

Without a saved plan file, `terraform apply` supports all planning modes and planning options available for `terraform plan`.

- **[Planning Modes](/terraform/cli/commands/plan#planning-modes):** These include `-destroy`, which creates a plan to destroy all remote objects, and `-refresh-only`, which creates a plan to update Terraform state and root module output values.
- **[Planning Options](/terraform/cli/commands/plan#planning-options):** These include specifying which resource instances Terraform should replace (`-replace`), setting Terraform input variables (`-var` and `-var-file`), etc.

### Apply Options

The following options change how the apply command executes and reports on the apply operation.

- `-auto-approve` - Skips interactive approval of the plan before applying. Terraform ignores this
  option when you pass a previously-saved plan file. This is because
  Terraform interprets the act of passing the plan file as the approval.

- `-compact-warnings` - Shows any warning messages in a compact form which
  includes only the summary messages, unless the warnings are accompanied by
  at least one error and thus the warning text might be useful context for
  the errors.

- `-input=false` - Disables all of Terraform's interactive prompts. Note that
  this also prevents Terraform from prompting for interactive approval of a
  plan, so Terraform will conservatively assume that you do not wish to
  apply the plan, causing the operation to fail. If you wish to run Terraform
  in a non-interactive context, see
  [Running Terraform in Automation](/terraform/tutorials/automation/automate-terraform?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) for some
  different approaches.

- `-json` - Enables the [machine readable JSON UI][machine-readable-ui] output.
  This implies `-input=false`, so the configuration must have no unassigned
  variable values to continue. To enable this flag, you must also either enable
  the `-auto-approve` flag or specify a previously-saved plan.

  [machine-readable-ui]: /terraform/internals/machine-readable-ui

- `-lock=false` - Don't hold a state lock during the operation. This is
  dangerous if others might concurrently run commands against the same
  workspace.

- `-lock-timeout=DURATION` - Unless locking is disabled with `-lock=false`,
  instructs Terraform to retry acquiring a lock for a period of time before
  returning an error. The duration syntax is a number followed by a time
  unit letter, such as "3s" for three seconds.

- `-no-color` - Disables terminal formatting sequences in the output. Use this
  if you are running Terraform in a context where its output will be
  rendered by a system that cannot interpret terminal formatting.

- `-parallelism=n` - Limit the number of concurrent operations as Terraform
  [walks the graph](/terraform/internals/graph#walking-the-graph). Defaults to
  10\.

- All [planning modes](/terraform/cli/commands/plan#planning-modes) and
[planning options](/terraform/cli/commands/plan#planning-options) for
`terraform plan` - Customize how Terraform will create the plan. Only available when you run `terraform apply` without a saved plan file.

For configurations using
[the `local` backend](/terraform/language/backend/local) only,
`terraform apply` also accepts the legacy options
[`-state`, `-state-out`, and `-backup`](/terraform/language/backend/local#command-line-arguments).

## Passing a Different Configuration Directory

Terraform v0.13 and earlier also accepted a directory path in place of the
plan file argument to `terraform apply`, in which case Terraform would use
that directory as the root module instead of the current working directory.

That usage was deprecated in Terraform v0.14 and removed in Terraform v0.15.
If your workflow relies on overriding the root module directory, use
[the `-chdir` global option](/terraform/cli/commands#switching-working-directory-with-chdir)
instead, which works across all commands and makes Terraform consistently look
in the given directory for all files it would normally read or write in the
current working directory.

If your previous use of this legacy pattern was also relying on Terraform
writing the `.terraform` subdirectory into the current working directory even
though the root module directory was overridden, use
[the `TF_DATA_DIR` environment variable](/terraform/cli/config/environment-variables#tf_data_dir)
to direct Terraform to write the `.terraform` directory to a location other
than the current working directory.


---
page_title: terraform destroy command reference
description: >-
  The `terraform destroy` command deprovisions all objects managed by a Terraform
  configuration.
---

# `terraform destroy` command

The `terraform destroy` command deprovisions all objects managed by a Terraform configuration.

While you will typically not want to destroy long-lived objects in a production
environment, Terraform is sometimes used to manage ephemeral infrastructure
for development purposes, in which case you can use `terraform destroy` to
conveniently clean up all of those temporary objects once you are finished
with your work.

## Usage

Usage: `terraform destroy [options]`

This command is just a convenience alias for the following command:

```
terraform apply -destroy
```

For that reason, this command accepts most of the options that
[`terraform apply`](/terraform/cli/commands/apply) accepts, although it does
not accept a plan file argument and forces the selection of the "destroy"
planning mode.

You can also create a speculative destroy plan, to see what the effect of
destroying would be, by running the following command:

```
terraform plan -destroy
```

This will run [`terraform plan`](/terraform/cli/commands/plan) in _destroy_ mode, showing
you the proposed destroy changes without executing them.

-> **Note:** The `-destroy` option to `terraform apply` exists only in
Terraform v0.15.2 and later. For earlier versions, you _must_ use
`terraform destroy` to get the effect of `terraform apply -destroy`.

### Target a specific resource

You can use the `-target` option to destroy a particular resource and its dependencies:



---
page_title: terraform plan command reference
description: >-
  The `terraform plan` command creates an execution plan with a preview of the
  changes that Terraform will make to your infrastructure.
---

# `terraform plan` command 

The `terraform plan` command creates an execution plan, which lets you preview
the changes that Terraform plans to make to your infrastructure. 

## Introduction
By default, Terraform performs the following operations when it creates a plan:

* Reads the current state of any already-existing remote objects to make sure
  that the Terraform state is up-to-date.
* Compares the current configuration to the prior state and noting any
  differences.
* Proposes a set of change actions that should, if applied, make the remote
  objects match the configuration.

> **Hands-on:** Try the [Terraform: Get Started](/terraform/tutorials/aws-get-started?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorials. For more in-depth details on the `plan` command, check out the [Create a Terraform Plan tutorial](/terraform/tutorials/cli/plan?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS).

The `plan` command alone does not actually carry out the proposed changes You can use this command to check whether the proposed changes match what
you expected before you apply the changes or share your changes with your
team for broader review.

If Terraform detects that no changes are needed to resource instances or to
root module output values, `terraform plan` will report that no actions need
to be taken.

If you are using Terraform directly in an interactive terminal and you expect
to apply the changes Terraform proposes, you can alternatively run
[`terraform apply`](/terraform/cli/commands/apply) directly. By default, the "apply" command
automatically generates a new plan and prompts for you to approve it.

You can use the optional `-out=FILE` option to save the generated plan to a
file on disk, which you can later execute by passing the file to
[`terraform apply`](/terraform/cli/commands/apply) as an extra argument. This two-step workflow
is primarily intended for when
[running Terraform in automation](/terraform/tutorials/automation/automate-terraform?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS).

If you run `terraform plan` without the `-out=FILE` option then it will create
a _speculative plan_, which is a description of the effect of the plan but
without any intent to actually apply it.

In teams that use a version control and code review workflow for making changes
to real infrastructure, developers can use speculative plans to verify the
effect of their changes before submitting them for code review. However, it's
important to consider that other changes made to the target system in the
meantime might cause the final effect of a configuration change to be different
than what an earlier speculative plan indicated, so you should always re-check
the final non-speculative plan before applying to make sure that it still
matches your intent.

## Usage

Usage: `terraform plan [options]`

The `plan` subcommand looks in the current working directory for the root module
configuration.

Because the plan command is one of the main commands of Terraform, it has
a variety of different options, described in the following sections. However,
most of the time you should not need to set any of these options, because
a Terraform configuration should typically be designed to work with no special
additional options for routine work.

The remaining sections on this page describe the various options:

* **[Planning Modes](#planning-modes)**: There are some special alternative
  planning modes that you can use for some special situations where your goal
  is not just to change the remote system to match your configuration.
* **[Planning Options](#planning-options)**: Alongside the special planning
  modes, there are also some options you can set in order to customize the
  planning process for unusual needs.
  * **[Resource Targeting](#resource-targeting)** is one particular
    special planning option that has some important caveats associated
    with it.
* **[Other Options](#other-options)**: These change the behavior of the planning
  command itself, rather than customizing the content of the generated plan.

## Planning Modes

The previous section describes Terraform's default planning behavior, which
changes the remote system to match the changes you make to
your configuration. Terraform has two alternative planning modes, each of which creates a plan with a different intended outcome. These options are available for  both `terraform plan` and [`terraform apply`](/terraform/cli/commands/apply).

* **Destroy mode:** creates a plan whose goal is to destroy all remote objects
  that currently exist, leaving an empty Terraform state. It is the same as running [`terraform destroy`](/terraform/cli/commands/destroy). Destroy mode can be useful for situations like transient development environments, where the managed objects cease to be useful once the development task is complete.

  Activate destroy mode using the `-destroy` command line option.

* **Refresh-only mode:** creates a plan whose goal is only to update the
  Terraform state and any root module output values to match changes made to
  remote objects outside of Terraform. This can be useful if you've
  intentionally changed one or more remote objects outside of the usual
  workflow (e.g. while responding to an incident) and you now need to reconcile
  Terraform's records with those changes.

  Activate refresh-only mode using the `-refresh-only` command line option.

In situations where we need to discuss the default planning mode that Terraform
uses when none of the alternative modes are selected, we refer to it as
"Normal mode". Because these alternative modes are for specialized situations
only, some other Terraform documentation only discusses the normal planning
mode.

The planning modes are all mutually-exclusive, so activating any non-default
planning mode disables the "normal" planning mode, and you can't use more than
one alternative mode at the same time.

-> **Note:** In Terraform v0.15 and earlier, the `-destroy` option is
supported only by the `terraform plan` command, and not by the
`terraform apply` command. To create and apply a plan in destroy mode in
earlier versions you must run [`terraform destroy`](/terraform/cli/commands/destroy).

-> **Note:** The `-refresh-only` option is available only in Terraform v0.15.4
and later.

> **Hands-on:** Try the [Use Refresh-Only Mode to Sync Terraform State](/terraform/tutorials/state/refresh) tutorial.

## Planning Options

In addition to alternate [planning modes](#planning-modes), there are several options that can modify planning behavior. These options are available for  both `terraform plan` and [`terraform apply`](/terraform/cli/commands/apply).

- `-refresh=false` - Disables the default behavior of synchronizing the
  Terraform state with remote objects before checking for configuration changes. This can make the planning operation faster by reducing the number of remote API requests. However, setting `refresh=false` causes Terraform to ignore external changes, which could result in an incomplete or incorrect plan. You cannot use `refresh=false` in refresh-only planning mode because it would effectively disable the entirety of the planning operation.

- `-replace=ADDRESS` - Instructs Terraform to plan to replace the
  resource instance with the given address. This is helpful when one or more remote objects have become degraded, and you can use replacement objects with the same configuration to align with immutable infrastructure patterns. Terraform will use a "replace" action if the specified resource would normally cause an "update" action or no action at all. Include this option multiple times to replace several objects at once. You cannot use `-replace` with the `-destroy` option, and it is only available from Terraform v0.15.2 onwards. For earlier versions, use [`terraform taint`](/terraform/cli/commands/taint) to achieve a similar result.

- `-target=ADDRESS` - Instructs Terraform to focus its planning efforts only
  on resource instances which match the given address and on any objects that
  those instances depend on.

  -> **Note:** Use `-target=ADDRESS` in exceptional circumstances only, such as recovering from mistakes or working around Terraform limitations. Refer to [Resource Targeting](#resource-targeting) for more details.

- `-var 'NAME=VALUE'` - Sets a value for a single
  [input variable](/terraform/language/values/variables) declared in the
  root module of the configuration. Use this option multiple times to set
  more than one variable. Refer to
  [Input Variables on the Command Line](#input-variables-on-the-command-line) for more information.

- `-var-file=FILENAME` - Sets values for potentially many
  [input variables](/terraform/language/values/variables) declared in the
  root module of the configuration, using definitions from a
  ["tfvars" file](/terraform/language/values/variables#variable-definitions-tfvars-files).
  Use this option multiple times to include values from more than one file.

There are several other ways to set values for input variables in the root
module, aside from the `-var` and `-var-file` options. Refer to
[Assigning Values to Root Module Variables](/terraform/language/values/variables#assigning-values-to-root-module-variables) for more information.

### Input Variables on the Command Line

You can use the `-var` command line option to specify values for
[input variables](/terraform/language/values/variables) declared in your
root module.

However, to do so will require writing a command line that is parsable both
by your chosen command line shell _and_ Terraform, which can be complicated
for expressions involving lots of quotes and escape sequences. In most cases
we recommend using the `-var-file` option instead, and write your actual values
in a separate file so that Terraform can parse them directly, rather than
interpreting the result of your shell's parsing.

~> **Warning:** Terraform will error if you include a space before or after the equals sign (e.g., `-var "length = 2"`).

To use `-var` on a Unix-style shell on a system like Linux or macOS we
recommend writing the option argument in single quotes `'` to ensure the
shell will interpret the value literally:

```
terraform plan -var 'name=value'
```

If your intended value also includes a single quote then you'll still need to
escape that for correct interpretation by your shell, which also requires
temporarily ending the quoted sequence so that the backslash escape character
will be significant:

```
terraform plan -var 'name=va'\''lue'
```

When using Terraform on Windows, we recommend using the Windows Command Prompt
(`cmd.exe`). When you pass a variable value to Terraform from the Windows
Command Prompt, use double quotes `"` around the argument:

```
terraform plan -var "name=value"
```

If your intended value includes literal double quotes then you'll need to
escape those with a backslash:

```
terraform plan -var "name=va\"lue"
```

PowerShell on Windows cannot correctly pass literal quotes to external programs,
so we do not recommend using Terraform with PowerShell when you are on Windows.
Use Windows Command Prompt instead.

The appropriate syntax for writing the variable value is different depending
on the variable's [type constraint](/terraform/language/expressions/type-constraints).
The primitive types `string`, `number`, and `bool` all expect a direct string
value with no special punctuation except that required by your shell, as
shown in the above examples. For all other type constraints, including list,
map, and set types and the special `any` keyword, you must write a valid
Terraform language expression representing the value, and write any necessary
quoting or escape characters to ensure it will pass through your shell
literally to Terraform. For example, for a `list(string)` type constraint:

```
# Unix-style shell
terraform plan -var 'name=["a", "b", "c"]'

# Windows Command Prompt (do not use PowerShell on Windows)
terraform plan -var "name=[\"a\", \"b\", \"c\"]"
```

Similar constraints apply when setting input variables using environment
variables. For more information on the various methods for setting root module
input variables, see
[Assigning Values to Root Module Variables](/terraform/language/values/variables#assigning-values-to-root-module-variables).

### Resource Targeting

> **Hands-on:** Try the [Target resources](/terraform/tutorials/state/resource-targeting?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorial.

You can use the `-target` option to focus Terraform's attention on only a
subset of resources.
You can use [resource address syntax](/terraform/cli/state/resource-addressing)
to specify the constraint. Terraform interprets the resource address as follows:

* If the given address identifies one specific resource instance, Terraform
  will select that instance alone. For resources with either `count` or
  `for_each` set, a resource instance address must include the instance index
  part, like `aws_instance.example[0]`.

* If the given address identifies a resource as a whole, Terraform will select
  all of the instances of that resource. For resources with either `count`
  or `for_each` set, this means selecting _all_ instance indexes currently
  associated with that resource. For single-instance resources (without
  either `count` or `for_each`), the resource address and the resource instance
  address are identical, so this possibility does not apply.

* If the given address identifies an entire module instance, Terraform will
  select all instances of all resources that belong to that module instance
  and all of its child module instances.

Once Terraform has selected one or more resource instances that you've directly
targeted, it will also then extend the selection to include all other objects
that those selections depend on either directly or indirectly.

This targeting capability is provided for exceptional circumstances, such
as recovering from mistakes or working around Terraform limitations. It
is _not recommended_ to use `-target` for routine operations, since this can
lead to undetected configuration drift and confusion about how the true state
of resources relates to configuration.

Instead of using `-target` as a means to operate on isolated portions of very
large configurations, prefer instead to break large configurations into
several smaller configurations that can each be independently applied.
[Data sources](/terraform/language/data-sources) can be used to access
information about resources created in other configurations, allowing
a complex system architecture to be broken down into more manageable parts
that can be updated independently.

## Other Options

The `terraform plan` command also has some other options that are related to
the input and output of the planning command, rather than customizing what
sort of plan Terraform will create. These commands are not necessarily also
available on `terraform apply`, unless otherwise stated in the documentation
for that command.

The available options are:

* `-compact-warnings` - Shows any warning messages in a compact form which
  includes only the summary messages, unless the warnings are accompanied by
  at least one error and thus the warning text might be useful context for
  the errors.

* `-detailed-exitcode` - Returns a detailed exit code when the command exits.
  When provided, this argument changes the exit codes and their meanings to
  provide more granular information about what the resulting plan contains:
  * 0 = Succeeded with empty diff (no changes)
  * 1 = Error
  * 2 = Succeeded with non-empty diff (changes present)

- `-generate-config-out=PATH` - (Experimental) If `import` blocks are present in configuration, instructs Terraform to generate HCL for any imported resources not already present. The configuration is written to a new file at PATH, which must not already exist, or Terraform will error. If the plan fails for another reason, Terraform may still attempt to write configuration.

* `-input=false` - Disables Terraform's default behavior of prompting for
  input for root module input variables that have not otherwise been assigned
  a value. This option is particularly useful when running Terraform in
  non-interactive automation systems.

* `-json` - Enables the [machine readable JSON UI][machine-readable-ui] output.
  This implies `-input=false`, so the configuration must have no unassigned
  variable values to continue.

  [machine-readable-ui]: /terraform/internals/machine-readable-ui

* `-lock=false` - Don't hold a state lock during the operation. This is
  dangerous if others might concurrently run commands against the same
  workspace.

* `-lock-timeout=DURATION` - Unless locking is disabled with `-lock=false`,
  instructs Terraform to retry acquiring a lock for a period of time before
  returning an error. The duration syntax is a number followed by a time
  unit letter, such as "3s" for three seconds.

* `-no-color` - Disables terminal formatting sequences in the output. Use this
  if you are running Terraform in a context where its output will be
  rendered by a system that cannot interpret terminal formatting.

* `-out=FILENAME` - Writes the generated plan to the given filename in an
  opaque file format that you can later pass to `terraform apply` to execute
  the planned changes, and to some other Terraform commands that can work with
  saved plan files.

  Terraform will allow any filename for the plan file, but a typical
  convention is to name it `tfplan`. **Do not** name the file with a suffix
  that Terraform recognizes as another file format; if you use a `.tf` suffix
  then Terraform will try to interpret the file as a configuration source
  file, which will then cause syntax errors for subsequent commands.

  The generated file is not in any standard format intended for consumption
  by other software, but the file _does_ contain your full configuration,
  all of the values associated with planned changes, and all of the plan
  options including the input variables. If your plan includes any sort of
  sensitive data, even if obscured in Terraform's terminal output, it will
  be saved in cleartext in the plan file. You should therefore treat any
  saved plan files as potentially-sensitive artifacts.

* `-parallelism=n` - Limit the number of concurrent operations as Terraform
  [walks the graph](/terraform/internals/graph#walking-the-graph). Defaults
  to 10.

For configurations using
[the `local` backend](/terraform/language/backend/local) only,
`terraform plan` accepts the legacy command line option
[`-state`](/terraform/language/backend/local#command-line-arguments).

### Passing a Different Configuration Directory

Terraform v0.13 and earlier accepted an additional positional argument giving
a directory path, in which case Terraform would use that directory as the root
module instead of the current working directory.

That usage was deprecated in Terraform v0.14 and removed in Terraform v0.15.
If your workflow relies on overriding the root module directory, use
[the `-chdir` global option](/terraform/cli/commands#switching-working-directory-with-chdir)
instead, which works across all commands and makes Terraform consistently look
in the given directory for all files it would normally read or write in the
current working directory.

If your previous use of this legacy pattern was also relying on Terraform
writing the `.terraform` subdirectory into the current working directory even
though the root module directory was overridden, use
[the `TF_DATA_DIR` environment variable](/terraform/cli/config/environment-variables#tf_data_dir)
to direct Terraform to write the `.terraform` directory to a location other
than the current working directory.



---
page_title: 'Command: providers'
description: >-
  The `terraform providers` command prints information about the providers
  required in the current configuration.
---

# Command: providers

The `terraform providers` command shows information about the
[provider requirements](/terraform/language/providers/requirements) of the
configuration in the current working directory, as an aid to understanding
where each requirement was detected from.

This command also has several subcommands with different purposes.

## Usage

Usage: `terraform providers`


---
page_title: terraform show command reference
description: The `terraform show` command provides human-readable output from a state or plan file. 
---

# `terraform show` command

The `terraform show` command provides human-readable output
from a state or plan file. Use the command to inspect a plan to ensure
that the planned operations are expected, or to inspect the current state
as Terraform sees it.


-> **Note:** When using the `-json` command-line flag, any sensitive values in
Terraform state will be displayed in plain text. For more information, see
[Sensitive Data in State](/terraform/language/state/sensitive-data).

## JSON Output

Add the `-json` command-line flag to generate machine-readable output.

For Terraform state files, including when no path is provided,
`terraform show -json` shows a JSON representation of the state.

For Terraform plan files, `terraform show -json` shows a JSON representation
of the plan, configuration, and current state.

If you updated providers that contain new schema versions since the state
was written, upgrade the state before so that Terraform can display it with
`show -json`. If you are viewing a plan, it must be created without
`-refresh=false`. If you are viewing a state file, run `terraform refresh`
first.

The output format is covered in detail in [JSON Output Format](/terraform/internals/json-format).

## Usage

Usage: `terraform show [options] [file]`

You may use `show` with a path to either a Terraform state file or plan
file. If you don't specify a file path, Terraform will show the latest state
snapshot.

This command accepts the following options:

* `-no-color` - Disables output with coloring

* `-json` - Displays machine-readable output from a state or plan file

-> JSON output via the `-json` option requires **Terraform v0.12 or later**.



---
page_title: terraform taint command reference
description: |-
  The `terraform taint` command marks specified objects in the Terraform state as tainted.
---

# `terraform taint` command

The `terraform taint` command marks specified objects in the Terraform state as tainted. Use the `terraform taint` command when objects become degraded or damaged. Terraform prompts you to replace the tainted objects in the next plan you create.

This command is deprecated. Instead, add the `-replace` option to your [`terraform apply` command](/terraform/cli/commands/apply).

## Recommended Alternative

For Terraform v0.15.2 and later, we recommend using the [`-replace` option](/terraform/cli/commands/plan#replace-address) with `terraform apply` to force Terraform to replace an object even though there are no configuration changes that would require it.

```
$ terraform apply -replace="aws_instance.example[0]"
```

We recommend the `-replace` option because the change will be reflected in the Terraform plan, letting you understand how it will affect your infrastructure before you take any externally-visible action. When you use `terraform taint`, other users could create a new plan against your tainted object before you can review the effects.

## Usage

```
$ terraform taint [options] <address>
```

The `address` argument is the address of the resource to mark as tainted.
The address is in
[the resource address syntax](/terraform/cli/state/resource-addressing),
as shown in the output from other commands, such as:

- `aws_instance.foo`
- `aws_instance.bar[1]`
- `aws_instance.baz[\"key\"]` (quotes in resource addresses must be escaped on the command line, so that they will not be interpreted by your shell)
- `module.foo.module.bar.aws_instance.qux`

This command accepts the following options:

- `-allow-missing` - If specified, the command will succeed (exit code 0)
  even if the resource is missing. The command might still return an error
  for other situations, such as if there is a problem reading or writing
  the state.

- `-lock=false` - Disables Terraform's default behavior of attempting to take
  a read/write lock on the state for the duration of the operation.

- `-lock-timeout=DURATION` - Unless locking is disabled with `-lock=false`,
  instructs Terraform to retry acquiring a lock for a period of time before
  returning an error. The duration syntax is a number followed by a time
  unit letter, such as "3s" for three seconds.

For configurations using the [HCP Terraform CLI integration](/terraform/cli/cloud) or the [`remote` backend](/terraform/language/backend/remote) only, `terraform taint`
also accepts the option
[`-ignore-remote-version`](/terraform/cli/cloud/command-line-arguments#ignore-remote-version).

For configurations using
[the `local` backend](/terraform/language/backend/local) only,
`terraform taint` also accepts the legacy options
[`-state`, `-state-out`, and `-backup`](/terraform/language/backend/local#command-line-arguments).




---
page_title: terraform validate command reference
description: >-
  The `terraform validate` command validates the syntax of Terraform configuration files in a directory.
---

# `terraform validate` command

The `terraform validate` command validates the configuration files in a
directory. It does not validate remote services, such as remote state or provider APIs.

## Introduction

Validate runs checks that verify whether a configuration is syntactically
valid and internally consistent, regardless of any provided variables or
existing state. It is thus primarily useful for general verification of
reusable modules, including correctness of attribute names and value types.

It is safe to run this command automatically, for example as a post-save
check in a text editor or as a test step for a reusable module in a CI
system.

Validation requires an initialized working directory with any referenced plugins and modules installed. To initialize a working directory for validation without accessing any configured backend, use:

```
$ terraform init -backend=false
```

To verify the configuration in the context of a particular run (a particular
target workspace, input variable values, etc), use the `terraform plan`
command instead, which includes an implied validation check.

## Usage

Usage: `terraform validate [options]`

This command accepts the following options:

* `-json` - Produce output in a machine-readable JSON format, suitable for
  use in text editor integrations and other automated systems. Always disables
  color.

* `-no-color` - If specified, output won't contain any color.

## JSON Output Format

When you use the `-json` option, Terraform will produce validation results
in JSON format to allow using the validation result for tool integrations, such
as highlighting errors in a text editor.

As with all JSON output options, it's possible that Terraform will encounter
an error prior to beginning the validation task that will thus not be subject
to the JSON output setting. For that reason, external software consuming
Terraform's output should be prepared to find data on stdout that _isn't_ valid
JSON, which it should then treat as a generic error case.

The output includes a `format_version` key, which as of Terraform 1.1.0 has
value `"1.0"`. The semantics of this version are:

* We will increment the minor version, e.g. `"1.1"`, for backward-compatible
  changes or additions. Ignore any object properties with unrecognized names to
  remain forward-compatible with future minor versions.
* We will increment the major version, e.g. `"2.0"`, for changes that are not
  backward-compatible. Reject any input which reports an unsupported major
  version.

We will introduce new major versions only within the bounds of
[the Terraform 1.0 Compatibility Promises](/terraform/language/v1-compatibility-promises).

In the normal case, Terraform will print a JSON object to the standard output
stream. The top-level JSON object will have the following properties:

- `valid` (boolean): Summarizes the overall validation result, by indicating
  `true` if Terraform considers the current configuration to be valid or
  `false` if it detected any errors.

- `error_count` (number): A zero or positive whole number giving the count
  of errors Terraform detected. If `valid` is `true` then `error_count` will
  always be zero, because it is the presence of errors that indicates that
  a configuration is invalid.

- `warning_count` (number): A zero or positive whole number giving the count
  of warnings Terraform detected. Warnings do not cause Terraform to consider
  a configuration to be invalid, but they do indicate potential caveats that
  a user should consider and possibly resolve.

- `diagnostics` (array of objects): A JSON array of nested objects that each
  describe an error or warning from Terraform.

The nested objects in `diagnostics` have the following properties:

- `severity` (string): A string keyword, either `"error"` or
  `"warning"`, indicating the diagnostic severity.

  The presence of errors causes Terraform to consider a configuration to be
  invalid, while warnings are just advice or caveats to the user which do not
  block working with the configuration. Later versions of Terraform may
  introduce new severity keywords, so consumers should be prepared to accept
  and ignore severity values they don't understand.

- `summary` (string): A short description of the nature of the problem that
  the diagnostic is reporting.

  In Terraform's usual human-oriented diagnostic messages, the summary serves
  as a sort of "heading" for the diagnostic, printed after the "Error:" or
  "Warning:" indicator.

  Summaries are typically short, single sentences, but can sometimes be longer
  as a result of returning errors from subsystems that are not designed to
  return full diagnostics, where the entire error message becomes the
  summary. In those cases, the summary might include newline characters which
  a renderer should honor when presenting the message visually to a user.

- `detail` (string): An optional additional message giving more detail about
  the problem.

  In Terraform's usual human-oriented diagnostic messages, the detail provides
  the paragraphs of text that appear after the heading and the source location
  reference.

  Detail messages are often multiple paragraphs and possibly interspersed with
  non-paragraph lines, so tools that aim to present detailed messages to the
  user should distinguish between lines without leading spaces, treating them
  as paragraphs, and lines with leading spaces, treating them as preformatted
  text. Renderers should then soft-wrap the paragraphs to fit the width of the
  rendering container, but leave the preformatted lines unwrapped.

  Some Terraform detail messages contain an approximation of bullet
  lists using ASCII characters to mark the bullets. This is not a
  contractual formatting convention, so renderers should avoid depending on
  it and should instead treat those lines as either paragraphs or preformatted
  text. 

- `range` (object): An optional object referencing a portion of the configuration
  source code that the diagnostic message relates to. For errors, this will
  typically indicate the bounds of the specific block header, attribute, or
  expression which was detected as invalid.

  A source range is an object with a property `filename` that gives the
  filename as a relative path from the current working directory, and then
  two properties `start` and `end` which are both themselves objects
  describing source positions, as described below.

  Not all diagnostic messages are connected with specific portions of the
  configuration, so `range` will be omitted or `null` for diagnostic messages
  where it isn't relevant.

- `snippet` (object): An optional object including an excerpt of the
  configuration source code that the diagnostic message relates to.

  The snippet information includes:

  - `context` (string): An optional summary of the root context of the
    diagnostic. For example, this might be the resource block containing the
    expression that triggered the diagnostic. For some diagnostics, this
    information is not available, and then this property will be `null`.

  - `code` (string): A snippet of Terraform configuration including the
    source of the diagnostic. This can be multiple lines and may include
    additional configuration source code around the expression which
    triggered the diagnostic.

  - `start_line` (number): A one-based line count representing the position
    in the source file at which the `code` excerpt begins. This is not
    necessarily the same value as `range.start.line`, as it is possible for
    `code` to include one or more lines of context before the source of the
    diagnostic.

  - `highlight_start_offset` (number): A zero-based character offset into the
    `code` string, pointing at the start of the expression which triggered
    the diagnostic.

  - `highlight_end_offset` (number): A zero-based character offset into the
    `code` string, pointing at the end of the expression which triggered the
    diagnostic.

  - `values` (array of objects): Contains zero or more expression values
    which may be useful in understanding the source of a diagnostic in a
    complex expression. These expression value objects are described below.

### Source Position

A source position object, as used in the `range` property of a diagnostic
object, has the following properties:

- `byte` (number): A zero-based byte offset into the indicated file.

- `line` (number): A one-based line count for the line containing the relevant
  position in the indicated file.

- `column` (number): A one-based count of _Unicode characters_ from the start
  of the line indicated in `line`.

A `start` position is inclusive while an `end` position is exclusive. The
exact positions used for particular error messages are intended for human
interpretation only.

### Expression Value

An expression value object gives additional information about a value that is
part of the expression which triggered the diagnostic. This is especially
useful when using `for_each` or similar constructs, in order to identify
exactly which values are responsible for an error. The object has two properties:

- `traversal` (string): An HCL-like traversal string, such as
  `var.instance_count`. Complex index key values may be elided, so this will
  not always be valid, parseable HCL. The contents of this string are intended
  to be human-readable.

- `statement` (string): A short English-language fragment describing the value
  of the expression when the diagnostic was triggered. The contents of this
  string are intended to be human-readable and are subject to change in future
  versions of Terraform.

---
page_title: terraform version command reference
description: >-
  The terraform version command prints the Terraform version and the version
  of all installed plugins.
---

# `terraform version` command

The `terraform version` command prints the current version of the Terraform binary and all
installed plugins.

## Usage

Usage: `terraform version [options]`

With no additional arguments, `version` displays the version of Terraform,
the platform it is installed on, installed providers, and the results of upgrade
and security checks unless disabled. Refer to [Upgrade and Security Bulletin Checks](/terraform/cli/commands#upgrade-and-security-bulletin-checks) for additional information.

## Flags

This command has one optional flag:

* `-json` - Formats version information as a JSON object. No upgrade or security information is included.

## Example

Basic usage, with upgrade and security information shown if relevant:

```shellsession
$ terraform version
Terraform v0.15.0
on darwin_amd64
+ provider registry.terraform.io/hashicorp/null v3.0.0

Your version of Terraform is out of date! The latest version
is X.Y.Z. You can update by downloading from https://www.terraform.io/downloads.html
```

As JSON:

```shellsession
$ terraform version -json
{
  "terraform_version": "0.15.0",
  "platform": "darwin_amd64",
  "provider_selections": {
    "registry.terraform.io/hashicorp/null": "3.0.0"
  },
  "terraform_outdated": true
}
```





  







  






