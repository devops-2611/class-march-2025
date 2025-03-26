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
