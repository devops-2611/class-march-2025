https://developer.hashicorp.com/terraform/language/resources

https://developer.hashicorp.com/terraform/language/resources/syntax



---
page_title: The count Meta-Argument - Configuration Language
description: >-
  Count helps you efficiently manage nearly identical infrastructure resources
  without writing a separate block for each one.
---

# The `count` Meta-Argument

-> **Version note:** Module support for `count` was added in Terraform 0.13, and
previous versions can only use it with resources.

-> **Note:** A given resource or module block cannot use both `count` and `for_each`.

> **Hands-on:** Try the [Manage Similar Resources With Count](/terraform/tutorials/0-13/count?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorial.

By default, a [resource block](/terraform/language/resources/syntax) configures one real
infrastructure object. (Similarly, a
[module block](/terraform/language/modules/syntax) includes a
child module's contents into the configuration one time.)
However, sometimes you want to manage several similar objects (like a fixed
pool of compute instances) without writing a separate block for each one.
Terraform has two ways to do this:
`count` and [`for_each`](/terraform/language/meta-arguments/for_each).

If a resource or module block includes a `count` argument whose value is a whole number,
Terraform will create that many instances.

## Basic Syntax

`count` is a meta-argument defined by the Terraform language. It can be used
with modules and with every resource type.

The `count` meta-argument accepts a whole number, and creates that many
instances of the resource or module. Each instance has a distinct infrastructure object
associated with it, and each is separately created,
updated, or destroyed when the configuration is applied.

```hcl
resource "aws_instance" "server" {
  count = 4 # create four similar EC2 instances

  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"

  tags = {
    Name = "Server ${count.index}"
  }
}
```

## The `count` Object

In blocks where `count` is set, an additional `count` object is
available in expressions, so you can modify the configuration of each instance.
This object has one attribute:

- `count.index` — The distinct index number (starting with `0`) corresponding
  to this instance.

## Using Expressions in `count`

The `count` meta-argument accepts numeric [expressions](/terraform/language/expressions).
However, unlike most arguments, the `count` value must be known
_before_ Terraform performs any remote resource actions. This means `count`
can't refer to any resource attributes that aren't known until after a
configuration is applied (such as a unique ID generated by the remote API when
an object is created).

## Referring to Instances

When `count` is set, Terraform distinguishes between the block itself
and the multiple _resource or module instances_ associated with it. Instances are
identified by an index number, starting with `0`.

- `<TYPE>.<NAME>` or `module.<NAME>` (for example, `aws_instance.server`) refers to the resource block.
- `<TYPE>.<NAME>[<INDEX>]` or `module.<NAME>[<INDEX>]` (for example, `aws_instance.server[0]`,
  `aws_instance.server[1]`, etc.) refers to individual instances.

This is different from resources and modules without `count` or `for_each`, which can be
referenced without an index or key.

Similarly, resources from child modules with multiple instances are prefixed
with `module.<NAME>[<KEY>]` when displayed in plan output and elsewhere in the UI.
For a module without `count` or `for_each`, the address will not contain
the module index as the module's name suffices to reference the module.

-> **Note:** Within nested `provisioner` or `connection` blocks, the special
`self` object refers to the current _resource instance,_ not the resource block
as a whole.

## When to Use `for_each` Instead of `count`

If your instances are almost identical, `count` is appropriate. If some
of their arguments need distinct values that can't be directly derived from an
integer, it's safer to use `for_each`.

Before `for_each` was available, it was common to derive `count` from the
length of a list and use `count.index` to look up the original list value:

```hcl
variable "subnet_ids" {
  type = list(string)
}

resource "aws_instance" "server" {
  # Create one instance for each subnet
  count = length(var.subnet_ids)

  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
  subnet_id     = var.subnet_ids[count.index]

  tags = {
    Name = "Server ${count.index}"
  }
}
```

This was fragile, because the resource instances were still identified by their
_index_ instead of the string values in the list. If an element was removed from
the middle of the list, every instance _after_ that element would see its
`subnet_id` value change, resulting in more remote object changes than intended.
Using `for_each` gives the same flexibility without the extra churn.



---
page_title: The depends_on Meta-Argument - Configuration Language
description: >-
  The depends_on meta-argument allows you to handle hidden resource or module
  dependencies.
---

# The `depends_on` Meta-Argument

Use the `depends_on` meta-argument to handle hidden resource or module dependencies that Terraform cannot automatically infer. You only need to explicitly specify a dependency when a resource or module relies on another resource's behavior but does not access any of that resource's data in its arguments.

-> **Note:** Module support for `depends_on` was added in Terraform version 0.13, and prior versions can only use it with resources.


## Processing and Planning Consequences

The `depends_on` meta-argument instructs Terraform to complete all actions on the dependency object (including Read actions) before performing actions on the object declaring the dependency. When the dependency object is an entire module, `depends_on` affects the order in which Terraform processes all of the resources and data sources associated with that module. Refer to [Resource Dependencies](/terraform/language/resources/behavior#resource-dependencies) and [Data Resource Dependencies](/terraform/language/data-sources#data-resource-dependencies) for more details.

You should use `depends_on` as a last resort because it can cause Terraform to create more conservative plans that replace more resources than necessary. For example, Terraform may treat more values as unknown “(known after apply)” because it is uncertain what changes will occur on the upstream object. This is especially likely when you use `depends_on` for modules.

Instead of `depends_on`, we recommend using [expression references](/terraform/language/expressions/references) to imply dependencies when possible. Expression references let Terraform understand which value the reference derives from and avoid planning changes if that particular value hasn’t changed, even if other parts of the upstream object have planned changes.

## Usage

You can use the `depends_on` meta-argument in `module` blocks and in all `resource` blocks, regardless of resource type. It requires a list of references to other resources or child modules in the same calling module. This list cannot include arbitrary expressions because the `depends_on` value must be known before Terraform knows resource relationships and thus before it can safely evaluate expressions.

We recommend always including a comment that explains why using `depends_on` is necessary. The following example uses `depends_on` to handle a "hidden" dependency on the `aws_iam_instance_profile.example`.

```hcl
resource "aws_iam_role" "example" {
  name = "example"

  # assume_role_policy is omitted for brevity in this example. Refer to the
  # documentation for aws_iam_role for a complete example.
  assume_role_policy = "..."
}

resource "aws_iam_instance_profile" "example" {
  # Because this expression refers to the role, Terraform can infer
  # automatically that the role must be created first.
  role = aws_iam_role.example.name
}

resource "aws_iam_role_policy" "example" {
  name   = "example"
  role   = aws_iam_role.example.name
  policy = jsonencode({
    "Statement" = [{
      # This policy allows software running on the EC2 instance to
      # access the S3 API.
      "Action" = "s3:*",
      "Effect" = "Allow",
    }],
  })
}

resource "aws_instance" "example" {
  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"

  # Terraform can infer from this that the instance profile must
  # be created before the EC2 instance.
  iam_instance_profile = aws_iam_instance_profile.example

  # However, if software running in this EC2 instance needs access
  # to the S3 API in order to boot properly, there is also a "hidden"
  # dependency on the aws_iam_role_policy that Terraform cannot
  # automatically infer, so it must be declared explicitly:
  depends_on = [
    aws_iam_role_policy.example
  ]
}
```



---
page_title: The for_each Meta-Argument - Configuration Language
description: >-
  The for_each meta-argument allows you to manage similar infrastructure
  resources without writing a separate block for each one.
---

# The `for_each` Meta-Argument

By default, a [resource block](/terraform/language/resources/syntax) configures one real
infrastructure object (and similarly, a
[module block](/terraform/language/modules/syntax) includes a
child module's contents into the configuration one time).
However, sometimes you want to manage several similar objects (like a fixed
pool of compute instances) without writing a separate block for each one.
Terraform has two ways to do this:
[`count`](/terraform/language/meta-arguments/count) and `for_each`.

> **Hands-on:** Try the [Manage Similar Resources With For Each](/terraform/tutorials/configuration-language/for-each) tutorial.

If a resource or module block includes a `for_each` argument whose value is a map or
a set of strings, Terraform creates one instance for each member of
that map or set.

-> **Version note:** `for_each` was added in Terraform 0.12.6. Module support
for `for_each` was added in Terraform 0.13; previous versions can only use
it with resources.

-> **Note:** A given resource or module block cannot use both `count` and `for_each`.

## Basic Syntax

`for_each` is a meta-argument defined by the Terraform language. It can be used
with modules and with every resource type.

The `for_each` meta-argument accepts a map or a set of strings, and creates an
instance for each item in that map or set. Each instance has a distinct
infrastructure object associated with it, and each is separately created,
updated, or destroyed when the configuration is applied.

Map:

```hcl
resource "azurerm_resource_group" "rg" {
  for_each = tomap({
    a_group       = "eastus"
    another_group = "westus2"
  })
  name     = each.key
  location = each.value
}
```

Set of strings:

```hcl
resource "aws_iam_user" "the-accounts" {
  for_each = toset(["Todd", "James", "Alice", "Dottie"])
  name     = each.key
}
```

Child module:

```hcl
# my_buckets.tf
module "bucket" {
  for_each = toset(["assets", "media"])
  source   = "./publish_bucket"
  name     = "${each.key}_bucket"
}
```

```hcl
# publish_bucket/bucket-and-cloudfront.tf
variable "name" {} # this is the input parameter of the module

resource "aws_s3_bucket" "example" {
  # Because var.name includes each.key in the calling
  # module block, its value will be different for
  # each instance of this module.
  bucket = var.name

  # ...
}

resource "aws_iam_user" "deploy_user" {
  # ...
}
```

## The `each` Object

In blocks where `for_each` is set, an additional `each` object is
available in expressions, so you can modify the configuration of each instance.
This object has two attributes:

- `each.key` — The map key (or set member) corresponding to this instance.
- `each.value` — The map value corresponding to this instance. (If a set was
  provided, this is the same as `each.key`.)

## Limitations on values used in `for_each`

The keys of the map (or all the values in the case of a set of strings) must
be _known values_, or you will get an error message that `for_each` has dependencies
that cannot be determined before apply, and a `-target` may be needed.

`for_each` keys cannot be the result (or rely on the result of) of impure functions,
including `uuid`, `bcrypt`, or `timestamp`, as their evaluation is deferred during the
main evaluation step.

Sensitive values, such as [sensitive input variables](/terraform/language/values/variables#suppressing-values-in-cli-output),
[sensitive outputs](/terraform/language/values/outputs#sensitive-suppressing-values-in-cli-output),
or [sensitive resource attributes](/terraform/language/expressions/references#sensitive-resource-attributes),
cannot be used as arguments to `for_each`. The value used in `for_each` is used
to identify the resource instance and will always be disclosed in UI output,
which is why sensitive values are not allowed.
Attempts to use sensitive values as `for_each` arguments will result in an error.

If you transform a value containing sensitive data into an argument to be used in `for_each`, be aware that
[most functions in Terraform will return a sensitive result if given an argument with any sensitive content](/terraform/language/expressions/function-calls#using-sensitive-data-as-function-arguments).
In many cases, you can achieve similar results to a function used for this purpose by
using a `for` expression. For example, if you would like to call `keys(local.map)`, where
`local.map` is an object with sensitive values (but non-sensitive keys), you can create a
value to pass to  `for_each` with `toset([for k,v in local.map : k])`.

## Using Expressions in `for_each`

The `for_each` meta-argument accepts map or set [expressions](/terraform/language/expressions).
However, unlike most arguments, the `for_each` value must be known
_before_ Terraform performs any remote resource actions. This means `for_each`
can't refer to any resource attributes that aren't known until after a
configuration is applied (such as a unique ID generated by the remote API when
an object is created).

The `for_each` value must be a map or set with one element per desired resource
instance. To use a sequence as the `for_each` value, you must use an expression
that explicitly returns a set value, like the [toset](/terraform/language/functions/toset)
function. To prevent unwanted surprises during conversion, the `for_each` argument
does not implicitly convert lists or tuples to sets.
If you need to declare resource instances based on a nested
data structure or combinations of elements from multiple data structures you
can use Terraform expressions and functions to derive a suitable value.
For example:

- Transform a multi-level nested structure into a flat list by
  [using nested `for` expressions with the `flatten` function](/terraform/language/functions/flatten#flattening-nested-structures-for-for_each).
- Produce an exhaustive list of combinations of elements from two or more
  collections by
  [using the `setproduct` function inside a `for` expression](/terraform/language/functions/setproduct#finding-combinations-for-for_each).

### Chaining `for_each` Between Resources

Because a resource using `for_each` appears as a map of objects when used in
expressions elsewhere, you can directly use one resource as the `for_each`
of another in situations where there is a one-to-one relationship between
two sets of objects.

For example, in AWS an `aws_vpc` object is commonly associated with a number
of other objects that provide additional services to that VPC, such as an
"internet gateway". If you are declaring multiple VPC instances using `for_each`
then you can chain that `for_each` into another resource to declare an
internet gateway for each VPC:

```hcl
variable "vpcs" {
  type = map(object({
    cidr_block = string
  }))
}

resource "aws_vpc" "example" {
  # One VPC for each element of var.vpcs
  for_each = var.vpcs

  # each.value here is a value from var.vpcs
  cidr_block = each.value.cidr_block
}

resource "aws_internet_gateway" "example" {
  # One Internet Gateway per VPC
  for_each = aws_vpc.example

  # each.value here is a full aws_vpc object
  vpc_id = each.value.id
}

output "vpc_ids" {
  value = {
    for k, v in aws_vpc.example : k => v.id
  }

  # The VPCs aren't fully functional until their
  # internet gateways are running.
  depends_on = [aws_internet_gateway.example]
}
```

This chaining pattern explicitly and concisely declares the relationship
between the internet gateway instances and the VPC instances, which tells
Terraform to expect the instance keys for both to always change together,
and typically also makes the configuration easier to understand for human
maintainers.

## Referring to Instances

When `for_each` is set, Terraform distinguishes between the block itself
and the multiple _resource or module instances_ associated with it. Instances are
identified by a map key (or set member) from the value provided to `for_each`.

- `<TYPE>.<NAME>` or `module.<NAME>` (for example, `azurerm_resource_group.rg`) refers to the block.
- `<TYPE>.<NAME>[<KEY>]` or `module.<NAME>[<KEY>]` (for example, `azurerm_resource_group.rg["a_group"]`,
  `azurerm_resource_group.rg["another_group"]`, etc.) refers to individual instances.

This is different from resources and modules without `count` or `for_each`, which can be
referenced without an index or key.

Similarly, resources from child modules with multiple instances are prefixed
with `module.<NAME>[<KEY>]` when displayed in plan output and elsewhere in the UI.
For a module without `count` or `for_each`, the address will not contain
the module index as the module's name suffices to reference the module.

-> **Note:** Within nested `provisioner` or `connection` blocks, the special
`self` object refers to the current _resource instance,_ not the resource block
as a whole.

## Using Sets

The Terraform language doesn't have a literal syntax for
[set values](/terraform/language/expressions/type-constraints#collection-types), but you can use the `toset`
function to explicitly convert a list of strings to a set:

```hcl
locals {
  subnet_ids = toset([
    "subnet-abcdef",
    "subnet-012345",
  ])
}

resource "aws_instance" "server" {
  for_each = local.subnet_ids

  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
  subnet_id     = each.key # note: each.key and each.value are the same for a set

  tags = {
    Name = "Server ${each.key}"
  }
}
```

Conversion from list to set discards the ordering of the items in the list and
removes any duplicate elements. `toset(["b", "a", "b"])` will produce a set
containing only `"a"` and `"b"` in no particular order; the second `"b"` is
discarded.

If you are writing a module with an [input variable](/terraform/language/values/variables) that
will be used as a set of strings for `for_each`, you can set its type to
`set(string)` to avoid the need for an explicit type conversion:

```hcl
variable "subnet_ids" {
  type = set(string)
}

resource "aws_instance" "server" {
  for_each = var.subnet_ids

  # (and the other arguments as above)
}
```

---
page_title: The lifecycle Meta-Argument - Configuration Language
description: >-
  The meta-arguments in a lifecycle block allow you to customize resource
  behavior.
---

# The `lifecycle` Meta-Argument

> **Hands-on:** Try the [Lifecycle Management](/terraform/tutorials/state/resource-lifecycle?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorial.

The [Resource Behavior](/terraform/language/resources/behavior) page describes the general lifecycle for resources. Some details of
that behavior can be customized using the special nested `lifecycle` block
within a resource block body:

```hcl
resource "azurerm_resource_group" "example" {
  # ...

  lifecycle {
    create_before_destroy = true
  }
}
```

## Syntax and Arguments

`lifecycle` is a nested block that can appear within a resource block.
The `lifecycle` block and its contents are meta-arguments, available
for all `resource` blocks regardless of type.

The arguments available within a `lifecycle` block are `create_before_destroy`,
`prevent_destroy`, `ignore_changes`, and `replace_triggered_by`.

* `create_before_destroy` (bool) - By default, when Terraform must change
  a resource argument that cannot be updated in-place due to
  remote API limitations, Terraform will instead destroy the existing object
  and then create a new replacement object with the new configured arguments.

  The `create_before_destroy` meta-argument changes this behavior so that
  the new replacement object is created _first,_ and the prior object
  is destroyed after the replacement is created.

  This is an opt-in behavior because many remote object types have unique
  name requirements or other constraints that must be accommodated for
  both a new and an old object to exist concurrently. Some resource types
  offer special options to append a random suffix onto each object name to
  avoid collisions, for example. Terraform CLI cannot automatically activate
  such features, so you must understand the constraints for each resource
  type before using `create_before_destroy` with it.

  Note that Terraform propagates and applies the `create_before_destroy` meta-attribute
  behaviour to all resource dependencies. For example, if `create_before_destroy` is enabled on resource A but not on resource B, but resource A is dependent on resource B, then Terraform enables `create_before_destroy` for resource B 
  implicitly by default and stores it to the state file. You cannot override `create_before_destroy`
  to `false` on resource B because that would imply dependency cycles in the graph.

  Destroy provisioners of this resource do not run if `create_before_destroy`
  is set to `true`. 

* `prevent_destroy` (bool) - This meta-argument, when set to `true`, will
  cause Terraform to reject with an error any plan that would destroy the
  infrastructure object associated with the resource, as long as the argument
  remains present in the configuration.

  This can be used as a measure of safety against the accidental replacement
  of objects that may be costly to reproduce, such as database instances.
  However, it will make certain configuration changes impossible to apply,
  and will prevent the use of the `terraform destroy` command once such
  objects are created, and so this option should be used sparingly.

  Since this argument must be present in configuration for the protection to
  apply, note that this setting does not prevent the remote object from
  being destroyed if the `resource` block were removed from configuration
  entirely: in that case, the `prevent_destroy` setting is removed along
  with it, and so Terraform will allow the destroy operation to succeed.

* `ignore_changes` (list of attribute names) - By default, Terraform detects
  any difference in the current settings of a real infrastructure object
  and plans to update the remote object to match configuration.

  The `ignore_changes` feature is intended to be used when a resource is
  created with references to data that may change in the future, but should
  not affect said resource after its creation. In some rare cases, settings
  of a remote object are modified by processes outside of Terraform, which
  Terraform would then attempt to "fix" on the next run. In order to make
  Terraform share management responsibilities of a single object with a
  separate process, the `ignore_changes` meta-argument specifies resource
  attributes that Terraform should ignore when planning updates to the
  associated remote object.

  The arguments corresponding to the given attribute names are considered
  when planning a _create_ operation, but are ignored when planning an
  _update_. The arguments are the relative address of the attributes in the
  resource. Map and list elements can be referenced using index notation,
  like `tags["Name"]` and `list[0]` respectively.

  ```hcl
  resource "aws_instance" "example" {
    # ...

    lifecycle {
      ignore_changes = [
        # Ignore changes to tags, e.g. because a management agent
        # updates these based on some ruleset managed elsewhere.
        tags,
      ]
    }
  }
  ```

  Instead of a list, the special keyword `all` may be used to instruct
  Terraform to ignore _all_ attributes, which means that Terraform can
  create and destroy the remote object but will never propose updates to it.

  Only attributes defined by the resource type can be ignored.
  `ignore_changes` cannot be applied to itself or to any other meta-arguments.

* `replace_triggered_by` (list of resource or attribute references) -
  _Added in Terraform 1.2._ Replaces the resource when any of the referenced
  items change. Supply a list of expressions referencing managed resources,
  instances, or instance attributes. When used in a resource that uses `count`
  or `for_each`, you can use `count.index` or `each.key` in the expression to
  reference specific instances of other resources that are configured with the
  same count or collection.

  References trigger replacement in the following conditions:

  - If the reference is to a resource with multiple instances, a plan to
    update or replace any instance will trigger replacement.
  - If the reference is to a single resource instance, a plan to update or
    replace that instance will trigger replacement.
  - If the reference is to a single attribute of a resource instance, any
    change to the attribute value will trigger replacement.

  You can only reference managed resources in `replace_triggered_by`
  expressions. This lets you modify these expressions without forcing
  replacement.

  ```hcl
  resource "aws_appautoscaling_target" "ecs_target" {
    # ...
    lifecycle {
      replace_triggered_by = [
        # Replace `aws_appautoscaling_target` each time this instance of
        # the `aws_ecs_service` is replaced.
        aws_ecs_service.svc.id
      ]
    }
  }
  ```

  `replace_triggered_by` allows only resource addresses because the decision is based on the planned actions for all of the given resources. Plain values such as local values or input variables do not have planned actions of their own, but you can treat them with a resource-like lifecycle by using them with [the `terraform_data` resource type](/terraform/language/resources/terraform-data).

## Custom Condition Checks

You can add `precondition` and `postcondition` blocks with a `lifecycle` block to specify assumptions and guarantees about how resources and data sources operate. The following examples creates a precondition that checks whether the AMI is properly configured.

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

Custom conditions can help capture assumptions, helping future maintainers understand the configuration design and intent. They also return useful information about errors earlier and in context, helping consumers more easily diagnose issues in their configurations.

Refer to [Custom Conditions](/terraform/language/expressions/custom-conditions#preconditions-and-postconditions) for more details.

## Literal Values Only

The `lifecycle` settings all affect how Terraform constructs and traverses
the dependency graph. As a result, only literal values can be used because
the processing happens too early for arbitrary expression evaluation.





