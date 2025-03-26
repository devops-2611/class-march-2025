---
page_title: Expressions - Configuration Language
description: >-
  An overview of expressions to reference or compute values in Terraform
  configurations, including types, operators, and functions.
---

# Expressions

> **Hands-on:** Try the [Create Dynamic Expressions](/terraform/tutorials/configuration-language/expressions?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorial.

_Expressions_ refer to or compute values within a configuration.
The simplest expressions are just literal values, like `"hello"` or `5`,
but the Terraform language also allows more complex expressions such as
references to data exported by resources, arithmetic, conditional evaluation,
and a number of built-in functions.

Expressions can be used in a number of places in the Terraform language,
but some contexts limit which expression constructs are allowed,
such as requiring a literal value of a particular type or forbidding
[references to resource attributes](/terraform/language/expressions/references#references-to-resource-attributes).
Each language feature's documentation describes any restrictions it places on
expressions.

You can experiment with the behavior of Terraform's expressions from
the Terraform expression console, by running
[the `terraform console` command](/terraform/cli/commands/console).

The other pages in this section describe the features of Terraform's
expression syntax.

- [Types and Values](/terraform/language/expressions/types)
  documents the data types that Terraform expressions can resolve to, and the
  literal syntaxes for values of those types.

- [Strings and Templates](/terraform/language/expressions/strings)
  documents the syntaxes for string literals, including interpolation sequences
  and template directives.

- [References to Values](/terraform/language/expressions/references)
  documents how to refer to named values like variables and resource attributes.

- [Operators](/terraform/language/expressions/operators)
  documents the arithmetic, comparison, and logical operators.

- [Function Calls](/terraform/language/expressions/function-calls)
  documents the syntax for calling Terraform's built-in functions.

- [Conditional Expressions](/terraform/language/expressions/conditionals)
  documents the `<CONDITION> ? <TRUE VAL> : <FALSE VAL>` expression, which
  chooses between two values based on a bool condition.

- [For Expressions](/terraform/language/expressions/for)
  documents expressions like `[for s in var.list : upper(s)]`, which can
  transform a complex type value into another complex type value.

- [Splat Expressions](/terraform/language/expressions/splat)
  documents expressions like `var.list[*].id`, which can extract simpler
  collections from more complicated expressions.

- [Dynamic Blocks](/terraform/language/expressions/dynamic-blocks)
  documents a way to create multiple repeatable nested blocks within a resource
  or other construct.

- [Type Constraints](/terraform/language/expressions/type-constraints)
  documents the syntax for referring to a type, rather than a value of that
  type. Input variables expect this syntax in their `type` argument.

- [Version Constraints](/terraform/language/expressions/version-constraints)
  documents the syntax of special strings that define a set of allowed software
  versions. Terraform uses version constraints in several places.




---
page_title: Conditional Expressions - Configuration Language
description: >-
  Conditional expressions select one of two values. You can use them to define
  defaults to replace invalid values.
---

# Conditional Expressions

A _conditional expression_ uses the value of a boolean expression to select one of
two values.

> **Hands-on:** Try the [Create Dynamic Expressions](/terraform/tutorials/configuration-language/expressions?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorial.

## Syntax

The syntax of a conditional expression is as follows:

```hcl
condition ? true_val : false_val
```

If `condition` is `true` then the result is `true_val`. If `condition` is
`false` then the result is `false_val`.

A common use of conditional expressions is to define defaults to replace
invalid values:

```hcl
var.a == "" ? "default-a" : var.a
```

If `var.a` is an empty string then the result is `"default-a"`, but otherwise
it is the actual value of `var.a`.

## Conditions

The condition can be any expression that resolves to a boolean value. This will
usually be an expression that uses the equality, comparison, or logical
operators.

### Custom Condition Checks

You can create conditions that produce custom error messages for several types of objects in a configuration. For example, you can add a condition to an input variable that checks whether incoming image IDs are formatted properly.

Custom conditions can help capture assumptions, helping future maintainers understand the configuration design and intent. They also return useful information about errors earlier and in context, helping consumers more easily diagnose issues in their configurations.

Refer to [Custom Condition Checks](/terraform/language/expressions/custom-conditions#input-variable-validation) for details.

## Result Types

The two result values may be of any type, but they must both
be of the _same_ type so that Terraform can determine what type the whole
conditional expression will return without knowing the condition value.

If the two result expressions don't produce the same type then Terraform will
attempt to find a type that they can both convert to, and make those
conversions automatically if so.

For example, the following expression is valid and will always return a string,
because in Terraform all numbers can convert automatically to a string using
decimal digits:

```hcl
var.example ? 12 : "hello"
```

Relying on this automatic conversion behavior can be confusing for those who
are not familiar with Terraform's conversion rules though, so we recommend
being explicit using type conversion functions in any situation where there may
be some uncertainty about the expected result type.

The following example is contrived because it would be easier to write the
constant `"12"` instead of the type conversion in this case, but shows how to
use [`tostring`](/terraform/language/functions/tostring) to explicitly convert a number to
a string.

```hcl
var.example ? tostring(12) : "hello"
```




---
page_title: Dynamic Blocks - Configuration Language
description: >-
  Dynamic blocks automatically construct multi-level, nested block structures.
  Learn to configure dynamic blocks and understand their behavior.
---

# `dynamic` Blocks

Within top-level block constructs like resources, expressions can usually be
used only when assigning a value to an argument using the `name = expression`
form. This covers many uses, but some resource types include repeatable _nested
blocks_ in their arguments, which typically represent separate objects that
are related to (or embedded within) the containing object:

```hcl
resource "aws_elastic_beanstalk_environment" "tfenvtest" {
  name = "tf-test-name" # can use expressions here

  setting {
    # but the "setting" block is always a literal block
  }
}
```

You can dynamically construct repeatable nested blocks like `setting` using a
special `dynamic` block type, which is supported inside `resource`, `data`,
`provider`, and `provisioner` blocks:

```hcl
resource "aws_elastic_beanstalk_environment" "tfenvtest" {
  name                = "tf-test-name"
  application         = aws_elastic_beanstalk_application.tftest.name
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.11.4 running Go 1.12.6"

  dynamic "setting" {
    for_each = var.settings
    content {
      namespace = setting.value["namespace"]
      name = setting.value["name"]
      value = setting.value["value"]
    }
  }
}
```

A `dynamic` block acts much like a [`for` expression](/terraform/language/expressions/for), but produces
nested blocks instead of a complex typed value. It iterates over a given
complex value, and generates a nested block for each element of that complex
value.

- The label of the dynamic block (`"setting"` in the example above) specifies
  what kind of nested block to generate.
- The `for_each` argument provides the complex value to iterate over.
- The `iterator` argument (optional) sets the name of a temporary variable
  that represents the current element of the complex value. If omitted, the name
  of the variable defaults to the label of the `dynamic` block (`"setting"` in
  the example above).
- The `labels` argument (optional) is a list of strings that specifies the block
  labels, in order, to use for each generated block. You can use the temporary
  iterator variable in this value.
- The nested `content` block defines the body of each generated block. You can
  use the temporary iterator variable inside this block.

Since the `for_each` argument accepts any collection or structural value,
you can use a `for` expression or splat expression to transform an existing
collection.

The iterator object (`setting` in the example above) has two attributes:

- `key` is the map key or list element index for the current element. If the
  `for_each` expression produces a _set_ value then `key` is identical to
  `value` and should not be used.
- `value` is the value of the current element.

A `dynamic` block can only generate arguments that belong to the resource type,
data source, provider or provisioner being configured. It is _not_ possible
to generate meta-argument blocks such as `lifecycle` and `provisioner`
blocks, since Terraform must process these before it is safe to evaluate
expressions.

The `for_each` value must be a collection with one element per desired
nested block. If you need to declare resource instances based on a nested
data structure or combinations of elements from multiple data structures you
can use Terraform expressions and functions to derive a suitable value.
For some common examples of such situations, see the
[`flatten`](/terraform/language/functions/flatten)
and
[`setproduct`](/terraform/language/functions/setproduct)
functions.

## Multi-level Nested Block Structures

Some providers define resource types that include multiple levels of blocks
nested inside one another. You can generate these nested structures dynamically
when necessary by nesting `dynamic` blocks in the `content` portion of other
`dynamic` blocks.

For example, a module might accept a complex data structure like the following:

```hcl
variable "load_balancer_origin_groups" {
  type = map(object({
    origins = set(object({
      hostname = string
    }))
  }))
}
```

If you were defining a resource whose type expects a block for each origin
group and then nested blocks for each origin within a group, you could ask
Terraform to generate that dynamically using the following nested `dynamic`
blocks:

```hcl
  dynamic "origin_group" {
    for_each = var.load_balancer_origin_groups
    content {
      name = origin_group.key

      dynamic "origin" {
        for_each = origin_group.value.origins
        content {
          hostname = origin.value.hostname
        }
      }
    }
  }
```

When using nested `dynamic` blocks it's particularly important to pay attention
to the iterator symbol for each block. In the above example,
`origin_group.value` refers to the current element of the outer block, while
`origin.value` refers to the current element of the inner block.

If a particular resource type defines nested blocks that have the same type
name as one of their parents, you can use the `iterator` argument in each of
`dynamic` blocks to choose a different iterator symbol that makes the two
easier to distinguish.

## Best Practices for `dynamic` Blocks

Overuse of `dynamic` blocks can make configuration hard to read and maintain, so
we recommend using them only when you need to hide details in order to build a
clean user interface for a re-usable module. Always write nested blocks out
literally where possible.

If you find yourself defining most or all of a `resource` block's arguments and
nested blocks using directly-corresponding attributes from an input variable
then that might suggest that your module is not creating a useful abstraction.
It may be better for the calling module to define the resource itself then
pass information about it into your module. For more information on this design
tradeoff, see [When to Write a Module](/terraform/language/modules/develop#when-to-write-a-module)
and [Module Composition](/terraform/language/modules/develop/composition).




---
page_title: Function Calls - Configuration Language
description: >-
  Functions transform and combine values. Learn about Terraform's built-in
  functions.
---

# Function Calls

> **Hands-on:** Try the [Perform Dynamic Operations with Functions](/terraform/tutorials/configuration-language/functions?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) tutorial.

The Terraform language has a number of
[built-in functions](/terraform/language/functions) that can be used
in expressions to transform and combine values. These
are similar to the operators but all follow a common syntax:

```hcl
<FUNCTION NAME>(<ARGUMENT 1>, <ARGUMENT 2>)
```

The function name specifies which function to call. Each defined function
expects a specific number of arguments with specific value types, and returns a
specific value type as a result.

Some functions take an arbitrary number of arguments. For example, the `min`
function takes any amount of number arguments and returns the one that is
numerically smallest:

```hcl
min(55, 3453, 2)
```

A function call expression evaluates to the function's return value.

## Available Functions

For a full list of available functions, see
[the function reference](/terraform/language/functions).

## Expanding Function Arguments

If the arguments to pass to a function are available in a list or tuple value,
that value can be _expanded_ into separate arguments. Provide the list value as
an argument and follow it with the `...` symbol:

```hcl
min([55, 2453, 2]...)
```

The expansion symbol is three periods (`...`), not a Unicode ellipsis character
(`…`). Expansion is a special syntax that is only available in function calls.

## Using Sensitive Data as Function Arguments

When using sensitive data, such as [an input variable](/terraform/language/values/variables#suppressing-values-in-cli-output)
or [an output defined](/terraform/language/values/outputs#sensitive-suppressing-values-in-cli-output) as sensitive
as function arguments, the result of the function call will be marked as sensitive.

This is a conservative behavior that is true irrespective of the function being
called. For example, passing an object containing a sensitive input variable to
the `keys()` function will result in a list that is sensitive:

```shell
> local.baz
{
  "a" = (sensitive value)
  "b" = "dog"
}
> keys(local.baz)
(sensitive value)
```

## When Terraform Calls Functions

Most of Terraform's built-in functions are, in programming language terms,
[pure functions](https://en.wikipedia.org/wiki/Pure_function). This means that
their result is based only on their arguments and so it doesn't make any
practical difference when Terraform would call them.

However, a small subset of functions interact with outside state and so for
those it can be helpful to know when Terraform will call them in relation to
other events that occur in a Terraform run.

The small set of special functions includes
[`file`](/terraform/language/functions/file),
[`templatefile`](/terraform/language/functions/templatefile),
[`timestamp`](/terraform/language/functions/timestamp),
and [`uuid`](/terraform/language/functions/uuid).
If you are not working with these functions then you don't need
to read this section, although the information here may still be interesting
background information.

The `file` and `templatefile` functions are intended for reading files that
are included as a static part of the configuration and so Terraform will
execute these functions as part of initial configuration validation, before
taking any other actions with the configuration. That means you cannot use
either function to read files that your configuration might generate
dynamically on disk as part of the plan or apply steps.

The `timestamp` function returns a representation of the current system time
at the point when Terraform calls it, and the `uuid` function returns a random
result which differs on each call. Without any special behavior, these would
both cause the final configuration during the apply step not to match the
actions shown in the plan, which violates the Terraform execution model.

For that reason, Terraform arranges for both of those functions to produce
[unknown value](/terraform/language/expressions/references#values-not-yet-known) results during the
plan step, with the real result being decided only during the apply step.
For `timestamp` in particular, this means that the recorded time will be
the instant when Terraform began applying the change, rather than when
Terraform _planned_ the change.

For more details on the behavior of these functions, refer to their own
documentation pages.


---
page_title: Operators - Configuration Language
description: >-
  Operators transform or combine expressions. Learn about arithmetic, logical,
  equality, and comparison operators.
---

# Arithmetic and Logical Operators

An _operator_ is a type of expression that transforms or combines one or more
other expressions. Operators either combine two values in some way to
produce a third result value, or transform a single given value to
produce a single result.

Operators that work on two values place an operator symbol between the two
values, similar to mathematical notation: `1 + 2`. Operators that work on
only one value place an operator symbol before that value, like
`!true`.

The Terraform language has a set of operators for both arithmetic and logic,
which are similar to operators in programming languages such as JavaScript
or Ruby.

When multiple operators are used together in an expression, they are evaluated
in the following order of operations:

1. `!`, `-` (multiplication by `-1`)
1. `*`, `/`, `%`
1. `+`, `-` (subtraction)
1. `>`, `>=`, `<`, `<=`
1. `==`, `!=`
1. `&&`
1. `||`

Use parentheses to override the default order of operations. Without
parentheses, higher levels will be evaluated first, so Terraform will interpret
`1 + 2 * 3` as `1 + (2 * 3)` and _not_ as `(1 + 2) * 3`.

The different operators can be gathered into a few different groups with
similar behavior, as described below. Each group of operators expects its
given values to be of a particular type. Terraform will attempt to convert
values to the required type automatically, or will produce an error message
if automatic conversion is impossible.

The `?` character combined with the `:` character is part of a conditional expression in Terraform and is not considered an operator. For more information, refer to [Conditional Expressions](/terraform/language/expressions/conditionals#conditional-expressions).

## Arithmetic Operators

The arithmetic operators all expect number values and produce number values
as results:

* `a + b` returns the result of adding `a` and `b` together.
* `a - b` returns the result of subtracting `b` from `a`.
* `a * b` returns the result of multiplying `a` and `b`.
* `a / b` returns the result of dividing `a` by `b`.
* `a % b` returns the remainder of dividing `a` by `b`. This operator is
  generally useful only when used with whole numbers.
* `-a` returns the result of multiplying `a` by `-1`.

Terraform supports some other less-common numeric operations as
[functions](/terraform/language/expressions/function-calls). For example, you can calculate exponents
using
[the `pow` function](/terraform/language/functions/pow).

## Equality Operators

The equality operators both take two values of any type and produce boolean
values as results.

* `a == b` returns `true` if `a` and `b` both have the same type and the same
  value, or `false` otherwise.
* `a != b` is the opposite of `a == b`.

Because the equality operators require both arguments to be of exactly the
same type in order to decide equality, we recommend using these operators only
with values of primitive types or using explicit type conversion functions
to indicate which type you are intending to use for comparison.

Comparisons between structural types may produce surprising results if you
are not sure about the types of each of the arguments. For example,
`var.list == []` may seem like it would return `true` if `var.list` were an
empty list, but `[]` actually builds a value of type `tuple([])` and so the
two values can never match. In this situation it's often clearer to write
`length(var.list) == 0` instead.

## Comparison Operators

The comparison operators all expect number values and produce boolean values
as results.

* `a < b` returns `true` if `a` is less than `b`, or `false` otherwise.
* `a <= b` returns `true` if `a` is less than or equal to `b`, or `false`
  otherwise.
* `a > b` returns `true` if `a` is greater than `b`, or `false` otherwise.
* `a >= b` returns `true` if `a` is greater than or equal to `b`, or `false` otherwise.

## Logical Operators

The logical operators all expect bool values and produce bool values as results.

* `a || b` returns `true` if either `a` or `b` is `true`, or `false` if both are `false`.
* `a && b` returns `true` if both `a` and `b` are `true`, or `false` if either one is `false`.
* `!a` returns `true` if `a` is `false`, and `false` if `a` is `true`.

Terraform does not have an operator for the "exclusive OR" operation. If you
know that both operators are boolean values then exclusive OR is equivalent
to the `!=` ("not equal") operator.

The logical operators in Terraform do not short-circuit, meaning `var.foo && var.foo.bar` will produce an error message if `var.foo` is `null` because both `var.foo` and `var.foo.bar` are evaluated.


---
page_title: Types and Values - Configuration Language
description: >-
  Learn about value types and syntax, including string, number, bool, list, and
  map. Also learn about complex types and type conversion.
---

# Types and Values

The result of an expression is a _value_. All values have a _type_, which
dictates where that value can be used and what transformations can be
applied to it.

## Types

The Terraform language uses the following types for its values:

* `string`: a sequence of Unicode characters representing some text, like
  `"hello"`.
* `number`: a numeric value. The `number` type can represent both whole
  numbers like `15` and fractional values like `6.283185`.
* `bool`: a boolean value, either `true` or `false`. `bool` values can be used in conditional
  logic.
* `list` (or `tuple`): a sequence of values, like `["us-west-1a", "us-west-1c"]`. Identify elements in a list with consecutive whole numbers, starting with zero.
* `set`: a collection of unique values that do not have any secondary identifiers or ordering.
* `map` (or `object`): a group of values identified by named labels, like
  `{name = "Mabel", age = 52}`.

Strings, numbers, and bools are sometimes called _primitive types._
Lists/tuples and maps/objects are sometimes called _complex types,_ _structural
types,_ or _collection types._ See
[Type Constraints](/terraform/language/expressions/type-constraints) for a more detailed
description of complex types.

Finally, there is one special value that has _no_ type:

* `null`: a value that represents _absence_ or _omission._ If you set an
  argument of a resource to `null`, Terraform behaves as though you
  had completely omitted it — it will use the argument's default value if it has
  one, or raise an error if the argument is mandatory. `null` is most useful in
  conditional expressions, so you can dynamically omit an argument if a
  condition isn't met.

## Literal Expressions

A _literal expression_ is an expression that directly represents a particular
constant value. Terraform has a literal expression syntax for each of the value
types described above.

### Strings

Strings are usually represented by a double-quoted sequence of Unicode
characters, `"like this"`. There is also a "heredoc" syntax for more complex
strings.

String literals are the most complex kind of literal expression in
Terraform, and have their own page of documentation. See [Strings](/terraform/language/expressions/strings)
for information about escape sequences, the heredoc syntax, interpolation, and
template directives.

### Numbers

Numbers are represented by unquoted sequences of digits with or without a
decimal point, like `15` or `6.283185`.

### Bools

Bools are represented by the unquoted symbols `true` and `false`.

### Null

The null value is represented by the unquoted symbol `null`.

### Lists/Tuples

Lists/tuples are represented by a pair of square brackets containing a
comma-separated sequence of values, like `["a", 15, true]`.

List literals can be split into multiple lines for readability, but always
require a comma between values. A comma after the final value is allowed,
but not required. Values in a list can be arbitrary expressions.

Lists and tuples each have different constraints on the types they allow. For more information on the types that each allows, refer to [tuples](/terraform/language/expressions/type-constraints#tuple) and [lists](/terraform/language/expressions/type-constraints#list).

### Sets

Terraform does not support directly accessing elements of a set by index because sets are unordered collections. To access elements in a set by index, first convert the set to a list.


1. Define a set. The following example specifies a set name `example_set`:

    ```hcl
    variable "example_set" {
      type    = set(string)
      default = ["foo", "bar"]
    }
    ```

1. Use the `tolist` function to convert the set to a list. The following example stores the converted list as a local variable called `example_list`: 

    ```hcl
    locals {
      example_list = tolist(var.example_set)
    }
    ```

1. You can then reference an element in the list:

    ```hcl
    output "first_element" {
      value = local.example_list[0]
    }
    output "second_element" {
      value = local.example_list[1]
    }
    ```

### Maps/Objects

Maps/objects are represented by a pair of curly braces containing a series of
`<KEY> = <VALUE>` pairs:

```hcl
{
  name = "John"
  age  = 52
}
```

Key/value pairs can be separated by either a comma or a line break.

The values in a map
can be arbitrary expressions.

The keys in a map must be strings; they can be left unquoted if
they are a valid [identifier](/terraform/language/syntax/configuration#identifiers), but must be quoted
otherwise. You can use a non-literal string expression as a key by wrapping it in
parentheses, like `(var.business_unit_tag_name) = "SRE"`.

## Indices and Attributes

[inpage-index]: #indices-and-attributes

Elements of list/tuple and map/object values can be accessed using
the square-bracket index notation, like `local.list[3]`. The expression within
the brackets must be a whole number for list and tuple values or a string
for map and object values.

Map/object attributes with names that are valid identifiers can also be accessed
using the dot-separated attribute notation, like `local.object.attrname`.
In cases where a map might contain arbitrary user-specified keys, we recommend
using only the square-bracket index notation (`local.map["keyname"]`).

## More About Complex Types

In most situations, lists and tuples behave identically, as do maps and objects.
Whenever the distinction isn't relevant, the Terraform documentation uses each
pair of terms interchangeably (with a historical preference for "list" and
"map").

However, module authors and provider developers should understand the
differences between these similar types (and the related `set` type), since they
offer different ways to restrict the allowed values for input variables and
resource arguments.

For complete details about these types (and an explanation of why the difference
usually doesn't matter), see [Type Constraints](/terraform/language/expressions/type-constraints).

## Type Conversion

Expressions are most often used to set values for the arguments of resources and
child modules. In these cases, the argument has an expected type and the given
expression must produce a value of that type.

Where possible, Terraform automatically converts values from one type to
another in order to produce the expected type. If this isn't possible, Terraform
will produce a type mismatch error and you must update the configuration with a
more suitable expression.

Terraform automatically converts number and bool values to strings when needed.
It also converts strings to numbers or bools, as long as the string contains a
valid representation of a number or bool value.

* `true` converts to `"true"`, and vice-versa
* `false` converts to `"false"`, and vice-versa
* `15` converts to `"15"`, and vice-versa



