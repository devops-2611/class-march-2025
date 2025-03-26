---
page_title:  Variables and Outputs
description: >-
  An overview of input variables, output values, and local values in Terraform
  language.
---

# Variables and Outputs

The Terraform language includes a few kinds of blocks for requesting or
publishing named values.

- [Input Variables](/terraform/language/values/variables) serve as parameters for
  a Terraform module, so users can customize behavior without editing the source.

- [Output Values](/terraform/language/values/outputs) are like return values for a
  Terraform module.

- [Local Values](/terraform/language/values/locals) are a convenience feature for
  assigning a short name to an expression.




---
page_title: Local Values - Configuration Language
description: >-
  Local values assign a name to an expression that can be used multiple times
  within a Terraform module.
---

# Local Values

> **Hands-on:** Try the [Simplify Terraform Configuration with Locals](/terraform/tutorials/configuration-language/locals?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorial.

A local value assigns a name to an [expression](/terraform/language/expressions),
so you can use the name multiple times within a module instead of repeating
the expression.

If you're familiar with traditional programming languages, it can be useful to
compare Terraform modules to function definitions:

- [Input variables](/terraform/language/values/variables) are like function arguments.
- [Output values](/terraform/language/values/outputs) are like function return values.
- Local values are like a function's temporary local variables.

-> **Note:** For brevity, local values are often referred to as just "locals"
when the meaning is clear from context.

## Declaring a Local Value

A set of related local values can be declared together in a single `locals`
block:

```hcl
locals {
  service_name = "forum"
  owner        = "Community Team"
}
```

The expressions in local values are not limited to literal constants; they can
also reference other values in the module in order to transform or combine them,
including variables, resource attributes, or other local values:

```hcl
locals {
  # Ids for multiple sets of EC2 instances, merged together
  instance_ids = concat(aws_instance.blue.*.id, aws_instance.green.*.id)
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}
```

## Ephemeral values

-> **Note**: Ephemeral local values are available in Terraform v1.10 and later.

Local values implicitly become ephemeral if you reference an ephemeral value when you assign that local a value. For example, you can create a local that references an ephemeral `service_token`.

```hcl
variable "service_name" {
  type    = string
  default = "forum"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "service_token" {
  type      = string
  ephemeral = true
}

locals {
  service_tag   = "${var.service_name}-${var.environment}"
  session_token = "${var.service_name}:${var.service_token}"
}
```

The `local.session_token` value is implicitly ephemeral because it relies on an ephemeral variable.

## Using Local Values

Once a local value is declared, you can reference it in
[expressions](/terraform/language/expressions) as `local.<NAME>`.

-> **Note:** Local values are _created_ by a `locals` block (plural), but you
_reference_ them as attributes on an object named `local` (singular). Make sure
to leave off the "s" when referencing a local value!

```hcl
resource "aws_instance" "example" {
  # ...

  tags = local.common_tags
}
```

A local value can only be accessed in expressions within the module where it
was declared.

## When To Use Local Values

Local values can be helpful to avoid repeating the same values or expressions
multiple times in a configuration, but if overused they can also make a
configuration hard to read by future maintainers by hiding the actual values
used.

Use local values only in moderation, in situations where a single value or
result is used in many places _and_ that value is likely to be changed in
future. The ability to easily change the value in a central place is the key
advantage of local values.





---
page_title: Output Values - Configuration Language
description: Output values are the return values of a Terraform module.
---

# Output Values

Output values make information about your infrastructure available on the
command line, and can expose information for other Terraform configurations to
use. Output values are similar to return values in programming languages.

> **Hands-on:** Try the [Output Data From
> Terraform](/terraform/tutorials/configuration-language/outputs)
> tutorial.

Output values have several uses:

- A child module can use outputs to expose a subset of its resource attributes
  to a parent module.
- A root module can use outputs to print certain values in the CLI output after
  running `terraform apply`.
- When using [remote state](/terraform/language/state/remote), root module outputs can be
  accessed by other configurations via a
  [`terraform_remote_state` data source](/terraform/language/state/remote-state-data).

Resource instances managed by Terraform each export attributes whose values
can be used elsewhere in configuration. Output values are a way to expose some
of that information to the user of your module.

-> **Note:** For brevity, output values are often referred to as just "outputs"
when the meaning is clear from context.

## Declaring an Output Value

Each output value exported by a module must be declared using an `output`
block:

```hcl
output "instance_ip_addr" {
  value = aws_instance.server.private_ip
}
```

The label immediately after the `output` keyword is the name, which must be a
valid [identifier](/terraform/language/syntax/configuration#identifiers). In a root module, this name is
displayed to the user; in a child module, it can be used to access the output's
value.

The `value` argument takes an [expression](/terraform/language/expressions)
whose result is to be returned to the user. In this example, the expression
refers to the `private_ip` attribute exposed by an `aws_instance` resource
defined elsewhere in this module (not shown). Any valid expression is allowed
as an output value.

-> **Note:** Outputs are only rendered when Terraform applies your plan. Running
`terraform plan` will not render outputs.

## Accessing Child Module Outputs

In a parent module, outputs of child modules are available in expressions as
`module.<MODULE NAME>.<OUTPUT NAME>`. For example, if a child module named
`web_server` declared an output named `instance_ip_addr`, you could access that
value as `module.web_server.instance_ip_addr`.


## Custom Condition Checks

You can use `precondition` blocks to specify guarantees about output data. The following examples creates a precondition that checks whether the EC2 instance has an encrypted root volume.

```hcl
output "api_base_url" {
  value = "https://${aws_instance.example.private_dns}:8433/"

  # The EC2 instance must have an encrypted root volume.
  precondition {
    condition     = data.aws_ebs_volume.example.encrypted
    error_message = "The server's root volume is not encrypted."
  }
}
```

Custom conditions can help capture assumptions, helping future maintainers understand the configuration design and intent. They also return useful information about errors earlier and in context, helping consumers more easily diagnose issues in their configurations.

Refer to [Custom Condition Checks](/terraform/language/expressions/custom-conditions#preconditions-and-postconditions) for more details.

## Optional Arguments

`output` blocks can optionally include `description`, `sensitive`, `ephemeral`, and `depends_on` arguments, which are described in the following sections.

<a id="description"></a>

### `description` — Output Value Documentation

Because the output values of a module are part of its user interface, you can
briefly describe the purpose of each value using the optional `description`
argument:

```hcl
output "instance_ip_addr" {
  value       = aws_instance.server.private_ip
  description = "The private IP address of the main server instance."
}
```

The description should concisely explain the
purpose of the output and what kind of value is expected. This description
string might be included in documentation about the module, and so it should be
written from the perspective of the user of the module rather than its
maintainer. For commentary for module maintainers, use comments.

<a id="ephemeral"></a>

### `ephemeral` — Avoid storing values in state or plan files

-> **Note**: Ephemeral outputs are available in Terraform v1.10 and later.

You can mark `output` values as `ephemeral` in child modules to pass ephemeral values between modules while avoiding persisting those values to state or plan files. This is useful for managing credentials, tokens, or other temporary resources you do not want to store in Terraform state files.

You can mark an `output` in a child module as ephemeral by setting the `ephemeral` attribute to `true`:

```hcl
# modules/db/main.tf

output "secret_id" {
  value       = aws_secretsmanager_secret.secret_id
  description = "Temporary secret ID for accessing database in AWS."
  ephemeral   = true
}
```

Terraform has access to the value of `output` blocks during plan and apply operations. At the end of a plan or apply operation, Terraform does not persist the value of any ephemeral outputs.

You can only reference ephemeral outputs in specific contexts or Terraform throws an error. The following are valid contexts for referencing ephemeral outputs:

* In a [write-only argument](/terraform/language/resources/ephemeral/write-only)
* In another child module's ephemeral `output` block
* In [ephemeral variables](/terraform/language/values/variables#exclude-values-from-state)
* In [ephemeral resources](/terraform/language/resources/ephemeral)

Note that you cannot set an `output` value as `ephemeral` in the root module.


<a id="sensitive"></a>

### `sensitive` — Suppressing Values in CLI Output

An output can be marked as containing sensitive material using the optional
`sensitive` argument:

```hcl
output "db_password" {
  value       = aws_db_instance.db.password
  description = "The password for logging in to the database."
  sensitive   = true
}
```

Terraform will hide values marked as sensitive in the messages from
`terraform plan` and `terraform apply`. In the following scenario, our root
module has an output declared as sensitive and a module call with a
sensitive output, which we then use in a resource attribute.

```hcl
# main.tf

module "foo" {
  source = "./mod"
}

resource "test_instance" "x" {
  some_attribute = module.foo.a # resource attribute references a sensitive output
}

output "out" {
  value     = "xyz"
  sensitive = true
}

# mod/main.tf, our module containing a sensitive output

output "a" {
  value     = "secret"
  sensitive = true
}
```

When we run a plan or apply, the sensitive value is redacted from output:

```
Terraform will perform the following actions:

  # test_instance.x will be created
  + resource "test_instance" "x" {
      + some_attribute    = (sensitive value)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + out = (sensitive value)
```

Terraform will still record sensitive values in the [state](/terraform/language/state),
and so anyone who can access the state data will have access to the sensitive
values in cleartext. For more information, see
[Sensitive Data in State](/terraform/language/state/sensitive-data).

<a id="depends_on"></a>

### `depends_on` — Explicit Output Dependencies

Since output values are just a means for passing data out of a module, it is
usually not necessary to worry about their relationships with other nodes in
the dependency graph.

However, when a parent module accesses an output value exported by one of its
child modules, the dependencies of that output value allow Terraform to
correctly determine the dependencies between resources defined in different
modules.

Just as with
[resource dependencies](/terraform/language/resources/behavior#resource-dependencies),
Terraform analyzes the `value` expression for an output value and automatically
determines a set of dependencies, but in less-common cases there are
dependencies that cannot be recognized implicitly. In these rare cases, the
`depends_on` argument can be used to create additional explicit dependencies:

```hcl
output "instance_ip_addr" {
  value       = aws_instance.server.private_ip
  description = "The private IP address of the main server instance."

  depends_on = [
    # Security group rule must be created before this IP address could
    # actually be used, otherwise the services will be unreachable.
    aws_security_group_rule.local_access,
  ]
}
```

The `depends_on` argument should be used only as a last resort. When using it,
always include a comment explaining why it is being used, to help future
maintainers understand the purpose of the additional dependency.




---
page_title: Input Variables - Configuration Language
description: >-
  Input variables allow you to customize modules without altering their source
  code. Learn how to declare, define, and reference variables in configurations.
---

# Input Variables

> **Hands-on:** Try the [Customize Terraform Configuration with Variables](/terraform/tutorials/configuration-language/variables?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorial.

Input variables let you customize aspects of Terraform modules without altering
the module's own source code. This functionality allows you to share modules across different
Terraform configurations, making your module composable and reusable.

When you declare variables in the root module of your configuration, you can
set their values using CLI options and environment variables.
When you declare them in [child modules](/terraform/language/modules),
the calling module should pass values in the `module` block.

If you're familiar with traditional programming languages, it can be useful to
compare Terraform modules to function definitions:

* Input variables are like function arguments.
* [Output values](/terraform/language/values/outputs) are like function return values.
* [Local values](/terraform/language/values/locals) are like a function's temporary local variables.

-> **Note:** For brevity, input variables are often referred to as just
"variables" or "Terraform variables" when it is clear from context what sort of
variable is being discussed. Other kinds of variables in Terraform include
_environment variables_ (set by the shell where Terraform runs) and _expression
variables_ (used to indirectly represent a value in an
[expression](/terraform/language/expressions)).

## Declaring an Input Variable

Each input variable accepted by a module must be declared using a `variable`
block:

```hcl
variable "image_id" {
  type = string
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["us-west-1a"]
}

variable "docker_ports" {
  type = list(object({
    internal = number
    external = number
    protocol = string
  }))
  default = [
    {
      internal = 8300
      external = 8300
      protocol = "tcp"
    }
  ]
}
```

The label after the `variable` keyword is a name for the variable, which must
be unique among all variables in the same module. This name is used to
assign a value to the variable from outside and to reference the variable's
value from within the module.

The name of a variable can be any valid [identifier](/terraform/language/syntax/configuration#identifiers)
_except_ the following: `source`, `version`, `providers`, `count`, `for_each`, `lifecycle`, `depends_on`, `locals`.

These names are reserved for meta-arguments in
[module configuration blocks](/terraform/language/modules/syntax), and cannot be
declared as variable names.

## Arguments

Terraform CLI defines the following optional arguments for variable declarations:

* [`default`][inpage-default] - A default value which then makes the variable optional.
* [`type`][inpage-type] - This argument specifies what value types are accepted for the variable.
* [`description`][inpage-description] - This specifies the input variable's documentation.
* [`validation`][inpage-validation] - A block to define validation rules, usually in addition to type constraints.
* [`ephemeral`][inpage-ephemeral] - This variable is available during runtime, but not written to state or plan files.
* [`sensitive`][inpage-sensitive] - Limits Terraform UI output when the variable is used in configuration.
* [`nullable`][inpage-nullable] - Specify if the variable can be `null` within the module.

### Default values

[inpage-default]: #default-values

The variable declaration can also include a `default` argument. If present,
the variable is considered to be _optional_ and the default value will be used
if no value is set when calling the module or running Terraform. The `default`
argument requires a literal value and cannot reference other objects in the
configuration.

### Type Constraints

[inpage-type]: #type-constraints

The `type` argument in a `variable` block allows you to restrict the
[type of value](/terraform/language/expressions/types) that will be accepted as
the value for a variable. If no type constraint is set then a value of any type
is accepted.

While type constraints are optional, we recommend specifying them; they
can serve as helpful reminders for users of the module, and they
allow Terraform to return a helpful error message if the wrong type is used.

Type constraints are created from a mixture of type keywords and type
constructors. The supported type keywords are:

* `string`
* `number`
* `bool`

The type constructors allow you to specify complex types such as
collections:

* `list(<TYPE>)`
* `set(<TYPE>)`
* `map(<TYPE>)`
* `object({<ATTR NAME> = <TYPE>, ... })`
* `tuple([<TYPE>, ...])`

The keyword `any` may be used to indicate that any type is acceptable. For
more information on the meaning and behavior of these different types, as well
as detailed information about automatic conversion of complex types, see
[Type Constraints](/terraform/language/expressions/types).

If both the `type` and `default` arguments are specified, the given default
value must be convertible to the specified type.

### Input Variable Documentation

[inpage-description]: #input-variable-documentation

Because the input variables of a module are part of its user interface, you can
briefly describe the purpose of each variable using the optional
`description` argument:

```hcl
variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
}
```

The description should concisely explain the purpose
of the variable and what kind of value is expected. This description string
might be included in documentation about the module, and so it should be written
from the perspective of the user of the module rather than its maintainer. For
commentary for module maintainers, use comments.

### Custom Validation Rules

[inpage-validation]: #custom-validation-rules

-> This feature was introduced in Terraform CLI v0.13.0.

You can specify custom validation rules for a particular variable by adding a `validation` block within the corresponding `variable` block. The example below checks whether the AMI ID has the correct syntax.

```hcl
variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."

  validation {
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}
```
Refer to [Custom Condition Checks](/terraform/language/expressions/custom-conditions#input-variable-validation) for more details.

### Exclude values from state

-> **Note**: Ephemeral variables are available in Terraform v1.10 and later.

[inpage-ephemeral]: #exclude-values-from-state

Setting a variable as `ephemeral` makes it available during runtime, but Terraform omits ephemeral values from state and plan files. Marking an input variable as `ephemeral` is useful for data that only needs to exist temporarily, such as a short-lived token or session identifier.

Mark an input variable as ephemeral by setting the `ephemeral` argument to `true`:

```hcl
variable "session_token" {
  type      = string
  ephemeral = true
}
```

Ephemeral variables are available during the current Terraform operation, and Terraform does not store them in state or plan files. So, unlike [`sensitive`](#sensitive) inputs, Terraform ensures ephemeral values are not available beyond the lifetime of the current Terraform run.

You can only reference ephemeral variables in specific contexts or Terraform throws an error. The following are valid contexts for referencing ephemeral variables:

* In a [write-only argument](/terraform/language/resources/ephemeral/write-only)
* Another ephemeral variable
* In [local values](/terraform/language/values/locals#ephemeral-values)
* In [ephemeral resources](/terraform/language/resources/ephemeral)
* In [ephemeral outputs](/terraform/language/values/outputs#ephemeral-avoid-storing-values-in-state-or-plan-files)
* Configuring providers in the `provider` block
* In [provisioner](/terraform/language/resources/provisioners/syntax) and [connection](/terraform/language/resources/provisioners/connection) blocks

If another expression references an `ephemeral` variable, that expression implicitly becomes ephemeral.

```hcl
variable "password" {
  type      = string
  ephemeral = true
}

locals {
  # local.database_password is implicitly ephemeral because 
  # var.password is ephemeral.
  database_password = var.password
}
```

The `local.database_password` value is implicitly ephemeral because it depends on `var.password`.

### Suppressing Values in CLI Output

[inpage-sensitive]: #suppressing-values-in-cli-output

> **Hands-on:** Try the [Protect Sensitive Input Variables](/terraform/tutorials/configuration-language/sensitive-variables?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorial.

Setting a variable as `sensitive` prevents Terraform from showing its value in
the `plan` or `apply` output, when you use that variable elsewhere in your
configuration.

Terraform will still record sensitive values in the [state](/terraform/language/state),
and so anyone who can access the state data will have access to the sensitive
values in cleartext. If you want to omit a value from state, mark that value as [`ephemeral`](#ephemeral). For more information, refer to
[Sensitive Data in State](/terraform/language/state/sensitive-data).

Declare a variable as sensitive by setting the `sensitive` argument to `true`:

```hcl
variable "user_information" {
  type = object({
    name    = string
    address = string
  })
  sensitive = true
}

resource "some_resource" "a" {
  name    = var.user_information.name
  address = var.user_information.address
}
```

Any expressions whose result depends on the sensitive variable will be treated
as sensitive themselves, and so in the above example the two arguments of
`resource "some_resource" "a"` will also be hidden in the plan output:

```
Terraform will perform the following actions:

  # some_resource.a will be created
  + resource "some_resource" "a" {
      + name    = (sensitive value)
      + address = (sensitive value)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

In some cases where you use a sensitive variable inside a nested block, Terraform
may treat the entire block as redacted. This happens for resource types where
all of the blocks of a particular type are required to be unique, and so
disclosing the content of one block might imply the content of a sibling block.

```
  # some_resource.a will be updated in-place
  ~ resource "some_resource" "a" {
      ~ nested_block {
          # At least one attribute in this block is (or was) sensitive,
          # so its contents will not be displayed.
        }
    }
```

A provider can also
[declare an attribute as sensitive](/terraform/plugin/sdkv2/best-practices/sensitive-state#using-the-sensitive-flag),
which will cause Terraform to hide it from regular output regardless of how
you assign it a value. For more information, see
[Sensitive Resource Attributes](/terraform/language/expressions/references#sensitive-resource-attributes).

If you use a sensitive value as part of an
[output value](/terraform/language/values/outputs) then Terraform will require
you to also mark the output value itself as sensitive, to confirm that you
intended to export it.

#### Cases where Terraform may disclose a sensitive variable

A `sensitive` variable is a configuration-centered concept, and values are sent to providers without any obfuscation. A provider error could disclose a value if that value is included in the error message. For example, a provider might return the following error even if "foo" is a sensitive value: `"Invalid value 'foo' for field"`

If a resource attribute is used as, or part of, the provider-defined resource id, an `apply` will disclose the value. In the example below, the `prefix` attribute has been set to a sensitive variable, but then that value ("jae") is later disclosed as part of the resource id:

```
  # random_pet.animal will be created
  + resource "random_pet" "animal" {
      + id        = (known after apply)
      + length    = 2
      + prefix    = (sensitive value)
      + separator = "-"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

...

random_pet.animal: Creating...
random_pet.animal: Creation complete after 0s [id=jae-known-mongoose]
```

### Disallowing Null Input Values

[inpage-nullable]: #disallowing-null-input-values

-> This feature is available in Terraform v1.1.0 and later.

The `nullable` argument in a variable block controls whether the module caller
may assign the value `null` to the variable.

```hcl
variable "example" {
  type     = string
  nullable = false
}
```

The default value for `nullable` is `true`. When `nullable` is `true`, `null`
is a valid value for the variable, and the module configuration must always
account for the possibility of the variable value being `null`. Passing a
`null` value as a module input argument will override any `default` value.

Setting `nullable` to `false` ensures that the variable value will never be
`null` within the module. If `nullable` is `false` and the variable has a
`default` value, then Terraform uses the default when a module input argument is `null`.

The `nullable` argument only controls where the direct value of the variable may be `null`.
For variables of collection or structural types, such as lists or objects,
the caller may still use `null` in nested elements or attributes, as long as
the collection or structure itself is not null.

## Using Input Variable Values

Within the module that declared a variable, its value can be accessed from
within [expressions](/terraform/language/expressions) as `var.<NAME>`,
where `<NAME>` matches the label given in the declaration block:

-> **Note:** Input variables are _created_ by a `variable` block, but you
_reference_ them as attributes on an object named `var`.

```hcl
resource "aws_instance" "example" {
  instance_type = "t2.micro"
  ami           = var.image_id
}
```

The value assigned to a variable can only be accessed in expressions within
the module where it was declared.

## Assigning Values to Root Module Variables

When variables are declared in the root module of your configuration, they
can be set in a number of ways:

* [In an HCP Terraform workspace](/terraform/cloud-docs/workspaces/variables).
* Individually, with the `-var` command line option.
* In variable definitions (`.tfvars`) files, either specified on the command line
  or automatically loaded.
* As environment variables.

The following sections describe these options in more detail. This section does
not apply to _child_ modules, where values for input variables are instead
assigned in the configuration of their parent module, as described in
[_Modules_](/terraform/language/modules).

### Variables on the Command Line

To specify individual variables on the command line, use the `-var` option
when running the `terraform plan` and `terraform apply` commands:

```
terraform apply -var="image_id=ami-abc123"
terraform apply -var='image_id_list=["ami-abc123","ami-def456"]' -var="instance_type=t2.micro"
terraform apply -var='image_id_map={"us-east-1":"ami-abc123","us-east-2":"ami-def456"}'
```

The above examples show appropriate syntax for Unix-style shells, such as on
Linux or macOS. For more information on shell quoting, including additional
examples for Windows Command Prompt, see
[Input Variables on the Command Line](/terraform/cli/commands/plan#input-variables-on-the-command-line).

You can use the `-var` option multiple times in a single command to set several
different variables.

<a id="variable-files"></a>

### Variable Definitions (`.tfvars`) Files

To set lots of variables, it is more convenient to specify their values in
a _variable definitions file_ (with a filename ending in either `.tfvars`
or `.tfvars.json`) and then specify that file on the command line with
`-var-file`:

Linux, Mac OS, and UNIX:

```shell
terraform apply -var-file="testing.tfvars"
```

PowerShell:

```shell
terraform apply -var-file='testing.tfvars'
```

Windows `cmd.exe`:

```shell
terraform apply -var-file="testing.tfvars"
```

-> **Note:** This is how HCP Terraform passes
[workspace variables](/terraform/cloud-docs/workspaces/variables) to Terraform.

A variable definitions file uses the same basic syntax as Terraform language
files, but consists only of variable name assignments:

```hcl
image_id = "ami-abc123"
availability_zone_names = [
  "us-east-1a",
  "us-west-1c",
]
```

Terraform also automatically loads a number of variable definitions files
if they are present:

* Files named exactly `terraform.tfvars` or `terraform.tfvars.json`.
* Any files with names ending in `.auto.tfvars` or `.auto.tfvars.json`.

Files whose names end with `.json` are parsed instead as JSON objects, with
the root object properties corresponding to variable names:

```json
{
  "image_id": "ami-abc123",
  "availability_zone_names": ["us-west-1a", "us-west-1c"]
}
```

### Environment Variables

As a fallback for the other ways of defining variables, Terraform searches
the environment of its own process for environment variables named `TF_VAR_`
followed by the name of a declared variable.

This can be useful when running Terraform in automation, or when running a
sequence of Terraform commands in succession with the same variables.
For example, at a `bash` prompt on a Unix system:

```
$ export TF_VAR_image_id=ami-abc123
$ terraform plan
...
```

On operating systems where environment variable names are case-sensitive,
Terraform matches the variable name exactly as given in configuration, and
so the required environment variable name will usually have a mix of upper
and lower case letters as in the above example.

### Complex-typed Values

When variable values are provided in a variable definitions file, you can use
Terraform's usual syntax for
[literal expressions](/terraform/language/expressions/types#literal-expressions)
to assign complex-typed values, like lists and maps.

Some special rules apply to the `-var` command line option and to environment
variables. For convenience, Terraform defaults to interpreting `-var` and
environment variable values as literal strings, which need only shell quoting,
and no special quoting for Terraform. For example, in a Unix-style shell:

```
$ export TF_VAR_image_id='ami-abc123'
```

However, if a root module variable uses a [type constraint](#type-constraints)
to require a complex value (list, set, map, object, or tuple), Terraform will
instead attempt to parse its value using the same syntax used within variable
definitions files, which requires careful attention to the string escaping rules
in your shell:

```
$ export TF_VAR_availability_zone_names='["us-west-1b","us-west-1d"]'
```

For readability, and to avoid the need to worry about shell escaping, we
recommend always setting complex variable values via variable definitions files.
For more information on quoting and escaping for `-var` arguments,
see
[Input Variables on the Command Line](/terraform/cli/commands/plan#input-variables-on-the-command-line).

### Values for Undeclared Variables

If you have defined a variable value, but not its corresponding `variable {}`
definition, you may get an error or warning depending on how you have provided
that value.

If you provide values for undeclared variables defined as [environment variables](#environment-variables)
you will not get an error or warning. This is because environment variables may
be declared but not used in all configurations that might be run.

If you provide values for undeclared variables defined [in a file](#variable-definitions-tfvars-files)
you will get a warning. This is to help in cases where you have provided a variable
value _meant_ for a variable declaration, but perhaps there is a mistake in the
value definition. For example, the following configuration:

```terraform
variable "moose" {
  type = string
}
```

And the following `.tfvars` file:

```hcl
mosse = "Moose"
```

Will cause Terraform to warn you that there is no variable declared `"mosse"`, which can help
you spot this mistake.

If you use `.tfvars` files across multiple configurations and expect to continue to see this warning,
you can use the [`-compact-warnings`](/terraform/cli/commands/plan#compact-warnings)
option to simplify your output.

If you provide values for undeclared variables on the [command line](#variables-on-the-command-line),
Terraform will return an error. To avoid this error, either declare a variable block for the value, or remove
the variable value from your Terraform call.

### Variable Definition Precedence

The above mechanisms for setting variables can be used together in any
combination. If the same variable is assigned multiple values, Terraform uses
the _last_ value it finds, overriding any previous values. Note that the same
variable cannot be assigned multiple values within a single source.

Terraform loads variables in the following order, with later sources taking
precedence over earlier ones:

* Environment variables
* The `terraform.tfvars` file, if present.
* The `terraform.tfvars.json` file, if present.
* Any `*.auto.tfvars` or `*.auto.tfvars.json` files, processed in lexical order
  of their filenames.
* Any `-var` and `-var-file` options on the command line, in the order they
  are provided. (This includes variables set by an HCP Terraform
  workspace.)

~> **Important:** In Terraform 0.12 and later, variables with map and object
values behave the same way as other variables: the last value found overrides
the previous values. This is a change from previous versions of Terraform, which
would _merge_ map values instead of overriding them.

#### Variable precedence within Terraform tests

Within Terraform test files, you can specify variable values within
`variables` blocks, either nested within `run` blocks or defined directly within
the file.

Variables defined in this way take precedence over all other mechanisms during
test execution, with variables defined within `run` blocks taking precedence
over those defined within the file.







  
