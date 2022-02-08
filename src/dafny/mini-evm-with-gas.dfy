/*
 * Copyright 2022 ConsenSys Software Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may 
 * not use this file except in compliance with the License. You may obtain 
 * a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software dis-
 * tributed under the License is distributed on an "AS IS" BASIS, WITHOUT 
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the 
 * License for the specific language governing permissions and limitations 
 * under the License.
 */


include "NonNativeTypes.dfy"
import opened NonNativeTypes

/** The type for the EVM stack. 
 * 
 *  @note   The stack can contain at most 1024 items which is not captured
 *          by this type definition. 
 */
type EVMStack = seq<uint256>

/** 
 *  Provide an initialiased EVM with a small instruction set.
 */
class EVM {

    /** The stack of the VM. */
    var stack: EVMStack

    var gas: uint256

    /** Init the VM. */
    constructor (g: uint256) 
        ensures stack == []
        ensures gas == g 
    {
        stack := []; 
        gas := g;
    }

    /** 
     *  PUSH1 opcode.
     */
    method push1(v: uint256) 
        requires gas >= 1

        ensures |stack| == |old(stack)| + 1
        ensures stack == [v] + old(stack)
        ensures gas == old(gas) - 1

        modifies `stack, `gas
    {
        stack := [v] + stack;
        gas := gas - 1;
    }

    /**
     *  POP opcode.
     */
    method pop() 
        requires |stack| > 0 
        requires gas >= 1

        ensures |stack| == |old(stack)| - 1
        ensures stack == old(stack)[1..]
        ensures gas == old(gas) - 1

        modifies `stack, `gas
    {
        stack := stack[1..];
        gas := gas - 1; 
    }

    /**
     *  SWAP1 opcode.
     */
    method swap1()  
        requires |stack| >= 2
        requires gas >= 1

        ensures |stack| == |old(stack)|
        ensures stack[0] == old(stack)[1]
        ensures stack[1] == old(stack)[0]
        ensures stack[2..] == old(stack)[2..]
        ensures gas == old(gas) - 1

        modifies `stack, `gas
    {
        stack := [stack[1]] + [stack[0]] + stack[2..];
        gas := gas  - 1;
    }


    /**
     *  ADD opcode.
     */
    method add()  
        requires |stack| >= 2
        requires stack[0] as nat + stack[1] as nat <= MAX_UINT256
        requires gas >= 1

        ensures |stack| == |old(stack)| - 1
        ensures stack[0] == old(stack)[0] + old(stack)[1]
        ensures stack[1..] == old(stack)[2..]
        ensures gas == old(gas) - 1

        modifies `stack, `gas
    {
        stack := [stack[0] + stack[1]] + stack[2..];
        gas := gas - 1;
    }

    /**
     *  SUB opcode. compute stack[1] - stack[0], which is not the semantics
     *  of SUB that is stack[0] - stack[1]
     */
    method subR()  
        requires |stack| >= 2
        requires stack[1] as nat - stack[0] as nat >= 0
        requires gas >= 1

        ensures |stack| == |old(stack)| - 1
        ensures stack[0] == old(stack)[1] - old(stack)[0]
        ensures stack[1..] == old(stack)[2..]
        ensures gas == old(gas) - 1

        modifies `stack, `gas
    {
        stack := [stack[1] - stack[0]] + stack[2..];
        gas := gas - 1;
    }

    /**
     *  SUB opcode. compute stack[0] - stack[1], which is the
     *  real semantics of sub 
     */
    method sub()  
        requires |stack| >= 2
        requires stack[0] as nat - stack[1] as nat >= 0
        requires gas >= 1

        ensures |stack| == |old(stack)| - 1
        ensures stack[0] == old(stack)[0] - old(stack)[1]
        ensures stack[1..] == old(stack)[2..]
        ensures gas == old(gas) - 1

        modifies `stack, `gas 
    {
        stack := [stack[0] - stack[1]] + stack[2..];
        gas := gas - 1;
    }

    /**
     *  DUP2 opcode. Duplicate the second element of the stack.
     */
    method dup2()  
        requires |stack| >= 2
        requires gas >= 1

        ensures |stack| == |old(stack)| + 1
        ensures stack == [old(stack)[1]] + old(stack)
        ensures gas == old(gas) - 1

        modifies `stack, `gas
    {
        stack := [stack[1]] + stack;
        gas := gas - 1;
    }

    /**
     *  GT opcode. Compute stack[0] > stack[1] and store result. 
     */
    method gt()  
        requires |stack| >= 2
        requires gas >= 1

        ensures |stack| == |old(stack)| - 1
        ensures stack == [if (old(stack)[0] > old(stack)[1]) then 1 else 0] + old(stack)[2..]
        ensures gas == old(gas) - 1

        modifies `stack, `gas
    {
        if (stack[0] > stack[1]) {
            stack := [1] + stack[2..];
        } else {
            stack := [0] + stack[2..];
        }
        gas := gas - 1;
    }

}