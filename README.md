<!-- [![Build Status](https://circleci.com/gh/ConsenSys/eth2.0-dafny.svg?style=shield)](https://circleci.com/gh/ConsenSys/workflows/eth2.0-dafny)  -->
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![made-for-VSCode](https://img.shields.io/badge/Made%20for-VSCode-1f425f.svg)](https://code.visualstudio.com/)
[![lemmas](https://img.shields.io/badge/Lemmas-0-yellow.svg)](https://shields.io/)
[![Common Tests Passing](https://img.shields.io/badge/Common%20Tests%20Passed-3232/3375-Blue.svg)](https://shields.io/)
[![Checks](https://img.shields.io/badge/DafnyVerify-Verified-orange.svg)](https://shields.io/)

 <!-- ![GitHub commit activity](https://img.shields.io/github/commit-activity/w/PegaSysEng/eth2.0-dafny?style=flat) -->

# Table of Contents

1. [Overview](#overview)
   1. [Dafny](#dafny)
   1. [Example](#semantics-example)
1. [Verifying Bytecode](#verifying-bytecode)
1. [Building](#building-the-code)
1. [Contributing](#contributing)
1. [Resources](#resources)

# Overview

In this project we develop the **Dafny-EVM**, a _functional specification_ of
the [Ethereum Virtual
Machine](https://ethereum.org/en/developers/docs/evm/) in
[Dafny](https://github.com/dafny-lang/dafny).  

This type of specification has several advantages:
- it is _programming-language agnostic_ and _easily readable_: it does not require any prior knowledge of a specific programming language, but rather defines the semantics of the EVM as functions and compositions thereof. [Read more](./SEMANTICS.md)
- it is _executable_: we can run EVM bytecode, and in effect we have an _interpreter_ of EVM bytecode. [Read more](./EXECUTION.md)
- it is _verified_. We guarantee that our EVM interpreter is free of runtime errors (e.g. division by zero, arithmetic under/overflow). [Read more](./GUARANTEES.md)
- it is provides a _usable API_ for _formal verification_ of EVM bytecode. [Read more](./VERIFICATION.md)


Developing this specification in Dafny allows us to apply [formal
reasoning](https://en.wikipedia.org/wiki/Formal_methods) to Smart
Contracts at the EVM Bytecode level.  For example, one can prove that
certain key properties are maintained by the contract.  We choose
Dafny over other verification systems
(e.g. [Coq](https://en.wikipedia.org/wiki/Coq) or
[Isabelle/HOL](https://en.wikipedia.org/wiki/Isabelle_(proof_assistant)))
because it is relatively accessible to someone without significant
prior experience.

Our functional specification is _executable_, meaning that we can
run bytecode using it and compare their output with existing clients
(e.g. [Geth](https://geth.ethereum.org/)).  In particular, we are
interested in comparing against the Ethereum [Common Reference
Tests](https://github.com/ethereum/tests) and have made some progress
towards this.

## Dafny

[Dafny](https://github.com/dafny-lang/dafny) supports automated
software verification by leveraging the power of state-of-the-art
automated theorem provers (e.g with [SMT
solvers](https://en.wikipedia.org/wiki/Satisfiability_modulo_theories)
like [Z3](https://en.wikipedia.org/wiki/Z3_Theorem_Prover)).  This
means Dafny can prove a program is **correct** with respect to its
_specification_.  To do this, Dafny requires the developer to provide
annotations in the form of 
[preconditions](https://en.wikipedia.org/wiki/Precondition) and
[postconditions](https://en.wikipedia.org/wiki/Postcondition) where
appropriate, and/or [loop
invariants](https://en.wikipedia.org/wiki/Loop_invariant) as
necessary.

<!-- _In this project, we are providing a specification of the Ethereum
Virtual Machine against which other programs (e.g. in EVM Bytecode)
can be verified._ -->

## Semantics Example

Our semantics is written as a state transformer of type `State -> State`.

As a simple example, consider the following specification given for
the semantics of the [`ADD`](https://ethereum.org/en/developers/docs/evm/opcodes/)
bytecode:

```Dafny
/**
 * Unsigned integer addition with modulo arithmetic.
 * @param   st  A state.
 * @returns     The state after executing an `ADD` or an `Error` state.
 */
function method Add(st: State): (st': State)
requires st.IsExecuting() 
ensures st'.OK? <==> st.Operands() >= 2
{
    if st.Operands() >= 2
    then
        var lhs := st.Peek(0) as int;
        var rhs := st.Peek(1) as int;
        var res := (lhs + rhs) % TWO_256;
        st.Pop().Pop().Push(res as u256).Next()
    else
        State.INVALID(STACK_UNDERFLOW)
}
```

This tells us that `ADD` requires _two operands_ on the stack to be performed,
otherwise, the exceptional state `INVALID(STACK_UNDERFLOW)` state is reached.  
When more than two operands are on the stack, 
addition employs _modulo arithmetic_ (hence, overflows wrap around)
and the final result (of the addition modulo) is pushed onto the stack after the operands
are popped, and then the program counter is advanced by 1.

The postcondition `ensures st'.OK? <==> st.Operands() >= 2` specifies a _strong guarantee_ on the code in the body of
function: **for any** input state `st`, `Add` returns an `OK` state (non-failure) _if and only if_ 
the stack in the input state `st` has at least two elements (`Operands()`).
Note that this postcondition is _checked_ by the Dafny verification engine at compile-time not at runtime.


# Getting Started 
To use our code base you may follow these steps:
- install a recent version of [Dafny](https://github.com/dafny-lang/dafny). We recommend installing the [VsCode Dafny extention](https://marketplace.visualstudio.com/items?itemName=dafny-lang.ide-vscode) as it bundles the editor interface (syntax coloring, error reporting, etc) and the Dafny compiler code.
- clone [this repository](https://github.com/ConsenSys/evm-dafny).
- either build the code (see below) or follow the step-by-step video on _how to use and verify 
some bytecode with the Dafny-EVM_.

# Verifying Bytecode 

Our EVM is written in Dafny. As a result we can instrument bytecode with some reasoning features.
Some examples are given in [the verification examples section.](./VERIFICATION.md)
# Building the Code

This repository uses [`gradle`](https://gradle.org/) as the de facto
build system.  To build the code, you need the following components:

* **[Java 11](https://openjdk.org/)** (or greater)

* **[Dafny 3.7](https://github.com/dafny-lang/dafny)** (or greater).

* **[Gradle 7](https://gradle.org)** (or greater)

With these installed, you can build the code using the following command:

```
> gradle build
```

This will verify the codebase using Dafny along with some examples,
generate a Java implementation of the `EVM`, and run two test suites
against it in Java.

# Test Generation

As the main purpose of our EVM is to reason about bytecode, we may want to have some guarantees that the proofs 
we develop are also valid on _other_ EVM implementations: if the same code is run on another implementation then the guarantees (e.g. no stack under/overflow) that we obtain using our automated reasoning and our EVM are still valid.
This requires to prove that the other implementation produces exactly the same computations as our EVM on all inputs and for all programs. 
It is not practical to formally prove this kind of equivalence.

However we can _compare_ the results of the execution of some bytecode on different implementations.
If for a large number of tests two implementations give the same results (sequences of states), we have some confidence
that the two implementations are _equivalent_.
If our EVM yields the same results as, say the Geth's `evm` tools, then we can be confident that our proofs on the bytecode should be valid on the Geth EVM too.


The test cases used for the Dafny EVM are stored in the `tests/`
directory.  These are generated from the [Ethereum Consensus
Tests](https://github.com/ethereum/tests) using Geth's `evm` tool.
Each test is a `json` file similar in structure to that used by the
Ethereum Consensus Tests, except that they include _full_ trace data
(i.e. the state of the EVM after every execution step).

To regenerate the trace tests, you need to ensure the `fixtures`
submodule is updated appropriately.  If you originally employed `git
clone --recursive` when cloning the repository, then you don't need to
do anything.  Otherwise, you can do this:

```
git submodule update --init
```

Using `gradle` one can now regenerate all the trace tests as follows:

```
> gradle testgen
```

This can take several minutes to complete, and requires that Geth's
`evm` tool is installed and visible on `PATH` (we currently recommend
version `1.10.25` or later).  Furthermore, the test generation process
is governed by the files `tests/includes.txt` and
`tests/excludes.txt`.  The former determines which of the reference
tests should be included, whilst the latter identifies specific cases
to exclude.  Finally, the trace generation process is managed by the
[EvmTools](https://github.com/DavePearce/EvmTools) framework.

# Contributing

See the [CONTRIBUTORS](CONTRIBUTORS.md) file for more information on
contributing to this repository.  By default contributors accept the
terms of the license.  We also endeavour to follow the conventions of
the Dafny [style
guide](https://github.com/dafny-lang/dafny/blob/master/docs/StyleGuide/Style-Guide.md).


# Resources
Some useful links:

* the Berlin version of the [yellow paper (YP)](https://ethereum.github.io/yellowpaper/paper.pdf)
* An complete [Introduction to the EVM](https://ethereum.org/en/developers/docs/evm/), Ethereum foundation
* A [Tutorial on the YP specification](https://ethereum.org/sr/developers/tutorials/yellow-paper-evm/),  (Ethereum foundation)
* the K-framework EVM semantics [KEVM, jellowpaper](https://jellopaper.org)
* the [Main EVM semantics](https://jellopaper.org/evm/) in Jellow paper (K framework)
* A [Quick reference to EVM opcodes](https://github.com/wolflo/evm-opcodes)
* An [Interactive reference to EVM opcodes](https://www.evm.codes)
* The Yul intermediate representation [Yul documentation](https://docs.soliditylang.org/en/v0.8.10/yul.html)
* Another proposal [Yul+](https://fuellabs.medium.com/introducing-yul-a-new-low-level-language-for-ethereum-aa64ce89512f)
