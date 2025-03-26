## Arguments and Blocks

The Terraform language syntax is built around two key syntax constructs:
arguments and blocks.

### Arguments

An _argument_ assigns a value to a particular name:

```hcl
image_id = "abc123"
```

The identifier before the equals sign is the _argument name_, and the expression
after the equals sign is the argument's value.

The context where the argument appears determines what value types are valid
(for example, each resource type has a schema that defines the types of its
arguments), but many arguments accept arbitrary
[expressions](/terraform/language/expressions), which allow the value to
either be specified literally or generated from other values programmatically.

-> **Note:** Terraform's configuration language is based on a more general
language called HCL, and HCL's documentation usually uses the word "attribute"
instead of "argument." These words are similar enough to be interchangeable in
this context, and experienced Terraform users might use either term in casual
conversation. But because Terraform also interacts with several _other_ things
called "attributes" (in particular, Terraform resources have attributes like
`id` that can be referenced from expressions but can't be assigned values in
configuration), we've chosen to use "argument" in the Terraform documentation
when referring to this syntax construct.

### Blocks

A _block_ is a container for other content:

```hcl
resource "aws_instance" "example" {
  ami = "abc123"

  network_interface {
    # ...
  }
}
```

A block has a _type_ (`resource` in this example). Each block type defines
how many _labels_ must follow the type keyword. The `resource` block type
expects two labels, which are `aws_instance` and `example` in the example above.
The `aws_instance` label is specific to the AWS provider. It specifies the `resource` type that Terraform provisions when you apply the configuration. The second label is an arbitrary name that you can add to the particular instance of the resource. You can create multiple instances of the same block type and differentiate them by giving each instance a unique name. In this example, the Terraform configuration author assigned the `example` label to this instance of the `aws_instance` resource. 
A particular block type may have any number of required labels, or it may
require none as with the nested `network_interface` block type.

After the block type keyword and any labels, the block _body_ is delimited
by the `{` and `}` characters. Within the block body, further arguments
and blocks may be nested, creating a hierarchy of blocks and their associated
arguments.

The Terraform language uses a limited number of _top-level block types,_ which
are blocks that can appear outside of any other block in a configuration file.
Most of Terraform's features (including resources, input variables, output
values, data sources, etc.) are implemented as top-level blocks.

## Identifiers

Argument names, block type names, and the names of most Terraform-specific
constructs like resources, input variables, etc. are all _identifiers_.

Identifiers can contain letters, digits, underscores (`_`), and hyphens (`-`).
The first character of an identifier must not be a digit, to avoid ambiguity
with literal numbers.

For complete identifier rules, Terraform implements
[the Unicode identifier syntax](http://unicode.org/reports/tr31/), extended to
include the ASCII hyphen character `-`.

## Comments

The Terraform language supports three different syntaxes for comments:

* `#` begins a single-line comment, ending at the end of the line.
* `//` also begins a single-line comment, as an alternative to `#`.
* `/*` and `*/` are start and end delimiters for a comment that might span
  over multiple lines.

The `#` single-line comment style is the default comment style and should be
used in most cases. Automatic configuration formatting tools may automatically
transform `//` comments into `#` comments, since the double-slash style is
not idiomatic.

## Character Encoding and Line Endings

Terraform configuration files must always be UTF-8 encoded. While the
delimiters of the language are all ASCII characters, Terraform accepts
non-ASCII characters in identifiers, comments, and string values.

Terraform accepts configuration files with either Unix-style line endings
(LF only) or Windows-style line endings (CR then LF), but the idiomatic style
is to use the Unix convention, and so automatic configuration formatting tools
may automatically transform CRLF endings to LF.


#######################################################################################

# Resources

_Resources_ are the most important element in the Terraform language.
Each resource block describes one or more infrastructure objects, such
as virtual networks, compute instances, or higher-level components such
as DNS records.

- [Resource Blocks](/terraform/language/resources/syntax) documents
  the syntax for declaring resources.

- [Resource Behavior](/terraform/language/resources/behavior) explains in
  more detail how Terraform handles resource declarations when applying a
  configuration.

- The Meta-Arguments section documents special arguments that can be used with
  every resource type, including
  [`depends_on`](/terraform/language/meta-arguments/depends_on),
  [`count`](/terraform/language/meta-arguments/count),
  [`for_each`](/terraform/language/meta-arguments/for_each),
  [`provider`](/terraform/language/meta-arguments/resource-provider),
  and [`lifecycle`](/terraform/language/meta-arguments/lifecycle).

- [Provisioners](/terraform/language/resources/provisioners/syntax)
  documents configuring post-creation actions for a resource using the
  `provisioner` and `connection` blocks. Since provisioners are non-declarative
  and potentially unpredictable, we strongly recommend that you treat them as a
  last resort.






# Resource Blocks

_Resources_ are the most important element in the Terraform language.
Each resource block describes one or more infrastructure objects, such
as virtual networks, compute instances, or higher-level components such
as DNS records.

For information about how Terraform manages resources after applying a configuration, refer to
[Resource Behavior](/terraform/language/resources/behavior).

## Resource Syntax

A `resource` block declares a resource of a specific type 
with a specific local name. Terraform uses the name when referring to the resource 
in the same module, but it has no meaning outside that module's scope.

In the following example,  the `aws_instance` resource type is named `web`. The resource type and name must be unique within a module because they serve as an identifier for a given resource.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
}
```

Within the block body (between `{` and `}`) are the configuration arguments
for the resource itself. The arguments often depend on the
resource type. In this example, both `ami` and `instance_type` are special 
arguments for [the `aws_instance` resource type](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).

-> **Note:** Resource names must start with a letter or underscore, and may
contain only letters, digits, underscores, and dashes.

Resource declarations can include more advanced features, such as single 
resource declarations that produce multiple similar remote objects, but only
a small subset is required for initial use. 

## Resource Types

Each resource is associated with a single _resource type_, which determines
the kind of infrastructure object it manages and what arguments and other
attributes the resource supports.

### Providers

A [provider](/terraform/language/providers/requirements) is a plugin for Terraform 
that offers a collection of resource types. Each resource type is implemented by a provider. A
provider provides resources to manage a single cloud or on-premises
infrastructure platform. Providers are distributed separately from Terraform, 
but Terraform can automatically install most providers when initializing
a working directory.

To manage resources, a Terraform module must specify the required providers. Refer to 
[Provider Requirements](/terraform/language/providers/requirements) for additional information.

Most providers need some configuration to access their remote API, 
which is provided by the root module. Refer to 
[Provider Configuration](/terraform/language/providers/configuration) for additional information.

Based on a resource type's name, Terraform can usually determine which provider to use. 
By convention, resource type names start with their provider's preferred local name.
When using multiple configurations of a provider or non-preferred local provider names, 
you must use [the `provider` meta-argument](/terraform/language/meta-arguments/resource-provider) 
to manually choose a provider configuration.

### Resource Arguments

Most of the arguments within the body of a `resource` block are specific to the
selected resource type. The resource type's documentation lists which arguments
are available and how their values should be formatted.

The values for resource arguments can make full use of
[expressions](/terraform/language/expressions) and other dynamic Terraform
language features.

[Meta-arguments](#meta-arguments) are defined by Terraform
and apply across all resource types. 

### Documentation for Resource Types

Every Terraform provider has its own documentation, describing its resource
types and their arguments.

Some provider documentation is still part of Terraform's core documentation, 
but the [Terraform Registry](https://registry.terraform.io/browse/providers) 
is the main home for all publicly available provider docs.

When viewing a provider's page on the Terraform
Registry, you can click the **Documentation** link in the header to browse its
documentation. The documentation is versioned. To choose a different version of the provider documentation, click on the version in the provider breadcrumbs to choose a version from the drop-down menu.

## Meta-Arguments

The Terraform language defines the following meta-arguments, which can be used with
any resource type to change the behavior of resources:

- [`depends_on`, for specifying hidden dependencies](/terraform/language/meta-arguments/depends_on)
- [`count`, for creating multiple resource instances according to a count](/terraform/language/meta-arguments/count)
- [`for_each`, to create multiple instances according to a map, or set of strings](/terraform/language/meta-arguments/for_each)
- [`provider`, for selecting a non-default provider configuration](/terraform/language/meta-arguments/resource-provider)
- [`lifecycle`, for lifecycle customizations](/terraform/language/meta-arguments/lifecycle)
- [`provisioner`, for taking extra actions after resource creation](/terraform/language/resources/provisioners/syntax)

## Removing Resources

-> **Note:** The `removed` block is available in Terraform v1.7 and later. For earlier Terraform versions, you can use the [`terraform state rm` CLI command](/terraform/cli/commands/state/rm) as a separate step.

To remove a resource from Terraform, simply delete the `resource` block from your Terraform configuration.

By default, after you remove the `resource` block, Terraform will plan to destroy any real infrastructure object managed by that resource.

Sometimes you may wish to remove a resource from your Terraform configuration without destroying the real infrastructure object it manages. In this case, the resource will be removed from the [Terraform state](/terraform/language/state), but the real infrastructure object will not be destroyed.

To declare that a resource was removed from Terraform configuration but that its managed object should not be destroyed, remove the `resource` block from your configuration and replace it with a `removed` block:

```hcl
removed {
  from = aws_instance.example

  lifecycle {
    destroy = false
  }
}
```

The `from` argument is the address of the resource you want to remove, without any instance keys (such as "aws_instance.example[1]").

The `lifecycle` block is required. The `destroy` argument determines whether Terraform will attempt to destroy the object managed by the resource or not. A value of `false` means that Terraform will remove the resource from state without destroying it.

A `removed` block may also contain a [Destroy-Time Provisioner](/terraform/language/resources/provisioners/syntax#destroy-time-provisioners), so that the provisioner can remain in the configuration even though the `resource` block has been removed.

```hcl
removed {
  from = aws_instance.example

  lifecycle {
    destroy = true
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Instance ${self.id} has been destroyed.'"
  }
}
```

The same referencing rules apply as in normal destroy-time provisioners, with only `count.index`, `each.key`, and `self` allowed. The provisioner must specify `when = destroy`, and the `removed` block must use `destroy = true` in order for the provisioner to execute.

## Custom Condition Checks

You can use `precondition` and `postcondition` blocks to specify assumptions and guarantees about how the resource operates. The following example creates a precondition that checks whether the AMI is properly configured.

```hcl
resource "aws_instance" "example" {
  instance_type = "t2.micro"
  ami           = "ami-abc123"

  lifecycle {
    # The AMI ID must refer to an AMI that contains an operating system
    # for the `x86_64` architecture.
    precondition {
      condition     = data.aws_ami.example.architecture == "x86_64"
      error_message = "The selected AMI must be for the x86_64 architecture."
    }
  }
}
```

[Custom condition checks](/terraform/language/expressions/custom-conditions#preconditions-and-postconditions) 
can help capture assumptions so that future maintainers 
understand the configuration design and intent. They also return useful 
information about errors earlier and in context, helping consumers to diagnose 
issues in their configuration.

## Operation Timeouts

Some resource types provide a special `timeouts` nested block argument that
allows you to customize how long certain operations are allowed to take
before being considered to have failed.
For example, [`aws_db_instance`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)
allows configurable timeouts for `create`, `update`, and `delete` operations.

Timeouts are handled entirely by the resource type implementation in the
provider, but resource types offering these features follow the convention
of defining a child block called `timeouts` that has a nested argument
named after each operation that has a configurable timeout value.
Each of these arguments takes a string representation of a duration, such
as `"60m"` for 60 minutes, `"10s"` for ten seconds, or `"2h"` for two hours.

```hcl
resource "aws_db_instance" "example" {
  # ...

  timeouts {
    create = "60m"
    delete = "2h"
  }
}
```

The set of configurable operations is chosen by each resource type. Most
resource types do not support the `timeouts` block at all. Consult the
documentation for each resource type to see which operations it offers
for configuration, if any.



#################################################################################




# Data Sources

_Data sources_ allow Terraform to use information defined outside of Terraform,
defined by another separate Terraform configuration, or modified by functions.

> **Hands-on:** Try the [Query Data Sources](/terraform/tutorials/configuration-language/data-sources) tutorial.

Each [provider](/terraform/language/providers) may offer data sources
alongside its set of [resource](/terraform/language/resources)
types.

## Using Data Sources

A data source is accessed via a special kind of resource known as a
_data resource_, declared using a `data` block:

```hcl
data "aws_ami" "example" {
  most_recent = true

  owners = ["self"]
  tags = {
    Name   = "app-server"
    Tested = "true"
  }
}
```

A `data` block requests that Terraform read from a given data source ("aws_ami")
and export the result under the given local name ("example"). The name is used
to refer to this resource from elsewhere in the same Terraform module, but has
no significance outside of the scope of a module.

The data source and name together serve as an identifier for a given
resource and so must be unique within a module.

Within the block body (between `{` and `}`) are query constraints defined by
the data source. Most arguments in this section depend on the
data source, and indeed in this example `most_recent`, `owners` and `tags` are
all arguments defined specifically for [the `aws_ami` data source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami).

When distinguishing from data resources, the primary kind of resource (as declared
by a `resource` block) is known as a _managed resource_. Both kinds of resources
take arguments and export attributes for use in configuration, but while
managed resources cause Terraform to create, update, and delete infrastructure
objects, data resources cause Terraform only to _read_ objects. For brevity,
managed resources are often referred to just as "resources" when the meaning
is clear from context.

## Data Source Arguments

Each data resource is associated with a single data source, which determines
the kind of object (or objects) it reads and what query constraint arguments
are available.

Each data source in turn belongs to a [provider](/terraform/language/providers),
which is a plugin for Terraform that offers a collection of resource types and
data sources that most often belong to a single cloud or on-premises
infrastructure platform.

Most of the items within the body of a `data` block are defined by and
specific to the selected data source, and these arguments can make full
use of [expressions](/terraform/language/expressions) and other dynamic
Terraform language features.

However, there are some "meta-arguments" that are defined by Terraform itself
and apply across all data sources. These arguments often have additional
restrictions on what language features can be used with them, and are described
in more detail in the following sections.

## Data Resource Behavior

Terraform reads data resources during the planning phase when possible, but
announces in the plan when it must defer reading resources until the apply
phase to preserve the order of operations. Terraform defers reading data
resources in the following situations:
* At least one of the given arguments is a managed resource attribute or
  other value that Terraform cannot predict until the apply step.
* The data resource depends directly on a managed resource that itself has
  planned changes in the current plan.
* The data resource has
  [custom conditions](#custom-condition-checks)
  and it depends directly or indirectly on a managed resource that itself
  has planned changes in the current plan.

Refer to [Data Resource Dependencies](#data-resource-dependencies) for details
on what it means for a data resource to depend on other objects. Any resulting
attribute of such a data resource will be unknown during planning, so it cannot
be used in situations where values must be fully known.

## Local-only Data Sources

While many data sources correspond to an infrastructure object type that
is accessed via a remote network API, some specialized data sources operate
only within Terraform itself, calculating some results and exposing them
for use elsewhere.

For example, local-only data sources exist for
[rendering templates](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file),
[reading local files](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file), and
[rendering AWS IAM policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document).

The behavior of local-only data sources is the same as all other data
sources, but their result data exists only temporarily during a Terraform
operation, and is re-calculated each time a new plan is created.

## Data Resource Dependencies

Data resources have the same dependency resolution behavior
[as defined for managed resources](/terraform/language/resources/behavior#resource-dependencies).
Setting the `depends_on` meta-argument within `data` blocks defers reading of
the data source until after all changes to the dependencies have been applied.

In order to ensure that data sources are accessing the most up to date
information possible in a wide variety of use cases, arguments directly
referencing managed resources are treated the same as if the resource was
listed in `depends_on`. This behavior can be avoided when desired by indirectly
referencing the managed resource values through a `local` value, unless the
data resource itself has
[custom conditions](#custom-condition-checks).

~> **NOTE:** **In Terraform 0.12 and earlier**, due to the data resource behavior of deferring the read until the apply phase when depending on values that are not yet known, using `depends_on` with `data` resources will force the read to always be deferred to the apply phase, and therefore a configuration that uses `depends_on` with a `data` resource can never converge. Due to this behavior, we do not recommend using `depends_on` with data resources.

## Custom Condition Checks

You can use `precondition` and `postcondition` blocks to specify assumptions and guarantees about how the data source operates. The following examples creates a postcondition that checks whether the AMI has the correct tags.

``` hcl
data "aws_ami" "example" {
  id = var.aws_ami_id

  lifecycle {
    # The AMI ID must refer to an existing AMI that has the tag "nomad-server".
    postcondition {
      condition     = self.tags["Component"] == "nomad-server"
      error_message = "tags[\"Component\"] must be \"nomad-server\"."
    }
  }
}
```

Custom conditions can help capture assumptions, helping future maintainers understand the configuration design and intent. They also return useful information about errors earlier and in context, helping consumers more easily diagnose issues in their configurations.

Refer to [Custom Condition Checks](/terraform/language/expressions/custom-conditions#preconditions-and-postconditions) for more details.


## Multiple Resource Instances

Data resources support [`count`](/terraform/language/meta-arguments/count)
and [`for_each`](/terraform/language/meta-arguments/for_each)
meta-arguments as defined for managed resources, with the same syntax and behavior.

As with managed resources, when `count` or `for_each` is present it is important to
distinguish the resource itself from the multiple resource _instances_ it
creates. Each instance will separately read from its data source with its
own variant of the constraint arguments, producing an indexed result.

## Selecting a Non-default Provider Configuration

Data resources support [the `provider` meta-argument](/terraform/language/meta-arguments/resource-provider)
as defined for managed resources, with the same syntax and behavior.

## Lifecycle Customizations

Data resources do not have any customization settings available
for their lifecycle. Only the `precondition` and `postcondition`
blocks are allowed in the data resource `lifecycle` block.

Refer to [Custom Condition Checks](#custom-condition-checks) for more details.

## Example

A data source configuration looks like the following:

```hcl
# Find the latest available AMI that is tagged with Component = web
data "aws_ami" "web" {
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:Component"
    values = ["web"]
  }

  most_recent = true
}
```

## Description

The `data` block creates a data instance of the given _type_ (first
block label) and _name_ (second block label). The combination of the type
and name must be unique.

Within the block (the `{ }`) is configuration for the data instance. The
configuration is dependent on the type; as with
[resources](/terraform/language/resources), each provider on the
[Terraform Registry](https://registry.terraform.io/browse/providers) has its own
documentation for configuring and using the data types it provides.

Each data instance will export one or more attributes, which can be
used in other resources as reference expressions of the form
`data.<TYPE>.<NAME>.<ATTRIBUTE>`. For example:

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.web.id
  instance_type = "t1.micro"
}
```

## Meta-Arguments

As data sources are essentially a read only subset of resources, they also
support the same [meta-arguments](/terraform/language/resources/syntax#meta-arguments) of resources
with the exception of the
[`lifecycle` configuration block](/terraform/language/meta-arguments/lifecycle).

### Non-Default Provider Configurations

Similarly to [resources](/terraform/language/resources), when
a module has multiple configurations for the same provider you can specify which
configuration to use with the `provider` meta-argument:

```hcl
data "aws_ami" "web" {
  provider = aws.west

  # ...
}
```

See
[The Resource `provider` Meta-Argument](/terraform/language/meta-arguments/resource-provider)
for more information.

## Data Source Lifecycle

If the arguments of a data instance contain no references to computed values,
such as attributes of resources that have not yet been created, then the
data instance will be read and its state updated during Terraform's "refresh"
phase, which by default runs prior to creating a plan. This ensures that the
retrieved data is available for use during planning and the diff will show
the real values obtained.

Data instance arguments may refer to computed values, in which case the
attributes of the instance itself cannot be resolved until all of its
arguments are defined. In this case, refreshing the data instance will be
deferred until the "apply" phase, and all interpolations of the data instance
attributes will show as "computed" in the plan since the values are not yet
known.


