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
include "../evm.dfy"
include "../bytecode.dfy"
include "../gas.dfy"

module EvmBerlin refines EVM {
    import opened Opcode
    import Bytecode
    import Gas

    /** An empty VM, with some gas.
     *
     *  @param  g   The gas loaded in this EVM.
     *  @returns    An ready-to-use EVM.
     */
    function method InitEmpty(gas: nat, code: seq<u8> := []): State
        requires |code| <= Code.MAX_CODE_SIZE
        ensures !InitEmpty(gas, code).IsFailure()
    {
        var tx := Context.Create(0x0,0,0,[],0);
        Create(tx, map[], gas, code)
    }

    /** The gas cost semantics of an opcode.
     *
     *  @param op   The opcode to look up.
     *  @param s    A state.
     *  @returns    The new state obtained having consumed the gas that corresponds to
     *              the cost of `opcode` is `s`.
     */
    function method OpGas(op: u8, s: State): State {
        match s
            case OK(_) => Gas.UseOneGas(op, s)
            case _ => s
    }

    /** The semantics of opcodes.
     *
     *  @param op   The opcode to look up.
     *  @param s    The state to apply the opcode to.
     *  @returns    The new state obtained after applying the semantics
     *              of the opcode.
     *  @note       If an opcode is not supported, or there is not enough gas
     *              the returned state is INVALID.
     */
    function method OpSem(op: u8, s: State): State {
        match s
            case OK(st) =>
                (
                    match op
                        case STOP =>  Bytecode.Stop(s)
                        case ADD =>  Bytecode.Add(s)
                        case MUL =>  Bytecode.Mul(s)
                        case SUB =>  Bytecode.Sub(s)
                        case DIV =>  Bytecode.Div(s)
                        case SDIV =>  Bytecode.SDiv(s)
                        case MOD =>  Bytecode.Mod(s)
                        case SMOD =>  Bytecode.SMod(s)
                        case ADDMOD =>  Bytecode.AddMod(s)
                        case MULMOD =>  Bytecode.MulMod(s)
                        case EXP =>  Bytecode.Exp(s)
                        //  SIGNEXTEND =>  Bytecode.evalSIGNEXTEND(s),
                        // 0x10s: Comparison & Bitwise Logic
                        case LT =>  Bytecode.Lt(s)
                        case GT =>  Bytecode.Gt(s)
                        case SLT =>  Bytecode.SLt(s)
                        case SGT =>  Bytecode.SGt(s)
                        case EQ =>  Bytecode.Eq(s)
                        case ISZERO =>  Bytecode.IsZero(s)
                        case AND =>  Bytecode.And(s)
                        case OR =>  Bytecode.Or(s)
                        case XOR =>  Bytecode.Xor(s)
                        case NOT =>  Bytecode.Not(s)
                        case BYTE =>  Bytecode.Byte(s)
                        case SHL =>  Bytecode.Shl(s)
                        case SHR =>  Bytecode.Shr(s)
                        case SAR => Bytecode.Sar(s)
                        // 0x20s
                        //  KECCAK256 =>  Some((s:OKState) => Bytecode.evalKECCAK256(s),)
                        // 0x30s: Environment Information
                        case ADDRESS => Bytecode.Address(s)
                        //  BALANCE => Bytecode.evalBALANCE(s),
                        case ORIGIN => Bytecode.Origin(s)
                        case CALLER => Bytecode.Caller(s)
                        case CALLVALUE => Bytecode.CallValue(s)
                        case CALLDATALOAD => Bytecode.CallDataLoad(s)
                        case CALLDATASIZE => Bytecode.CallDataSize(s)
                        case CALLDATACOPY => Bytecode.CallDataCopy(s)
                        case CODESIZE => Bytecode.CodeSize(s)
                        case CODECOPY => Bytecode.CodeCopy(s)
                        case GASPRICE => Bytecode.GasPrice(s)
                        //  EXTCODESIZE => Bytecode.evalEXTCODESIZE(s),
                        //  EXTCODECOPY => Bytecode.evalEXTCODECOPY(s),
                        //  RETURNDATASIZE => Bytecode.evalRETURNDATASIZE(s),
                        //  RETURNDATACOPY => Bytecode.evalRETURNDATACOPY(s),
                        //  EXTCODEHASH => Bytecode.evalEXTCODEHASH(s),
                        // 0x40s: Block Information
                        //  BLOCKHASH => Bytecode.evalBLOCKHASH(s),
                        //  COINBASE => Bytecode.evalCOINBASE(s),
                        //  TIMESTAMP => Bytecode.evalTIMESTAMP(s),
                        //  NUMBER => Bytecode.evalNUMBER(s),
                        //  DIFFICULTY => Bytecode.evalDIFFICULTY(s),
                        //  GASLIMIT => Bytecode.evalGASLIMIT(s),
                        //  CHAINID => Bytecode.evalCHAINID(s),
                        //  SELFBALANCE => Bytecode.evalSELFBALANCE(s),
                        // 0x50s: Stack, Memory, Storage and Flow
                        case POP => Bytecode.Pop(s)
                        case MLOAD => Bytecode.MLoad(s)
                        case MSTORE => Bytecode.MStore(s)
                        case MSTORE8 => Bytecode.MStore8(s)
                        case SLOAD => Bytecode.SLoad(s)
                        case SSTORE => Bytecode.SStore(s)
                        case JUMP => Bytecode.Jump(s)
                        case JUMPI => Bytecode.JumpI(s)
                        case PC => Bytecode.Pc(s)
                        case MSIZE => Bytecode.MSize(s)
                        case JUMPDEST =>  Bytecode.JumpDest(s)
                        // 0x60s & 0x70s: Push operations
                        case PUSH1 => Push(s,1)
                        case PUSH2 => Push(s,2)
                        case PUSH3 => Push(s,3)
                        case PUSH4 => Push(s,4)
                        case PUSH5 => Push(s,5)
                        case PUSH6 => Push(s,6)
                        case PUSH7 => Push(s,7)
                        case PUSH8 => Push(s,8)
                        case PUSH9 => Push(s,9)
                        case PUSH10 => Push(s,10)
                        case PUSH11 => Push(s,11)
                        case PUSH12 => Push(s,12)
                        case PUSH13 => Push(s,13)
                        case PUSH14 => Push(s,14)
                        case PUSH15 => Push(s,15)
                        case PUSH16 => Push(s,16)
                        case PUSH17 => Push(s,17)
                        case PUSH18 => Push(s,18)
                        case PUSH19 => Push(s,19)
                        case PUSH20 => Push(s,20)
                        case PUSH21 => Push(s,21)
                        case PUSH22 => Push(s,22)
                        case PUSH23 => Push(s,23)
                        case PUSH24 => Push(s,24)
                        case PUSH25 => Push(s,25)
                        case PUSH26 => Push(s,26)
                        case PUSH27 => Push(s,27)
                        case PUSH28 => Push(s,28)
                        case PUSH29 => Push(s,29)
                        case PUSH30 => Push(s,30)
                        case PUSH31 => Push(s,31)
                        case PUSH32 => Push(s,32)
                        // 0x80s: Duplicate operations
                        case DUP1 => Bytecode.Dup(s, 1)
                        case DUP2 => Bytecode.Dup(s, 2)
                        case DUP3 => Bytecode.Dup(s, 3)
                        case DUP4 => Bytecode.Dup(s, 4)
                        case DUP5 => Bytecode.Dup(s, 5)
                        case DUP6 => Bytecode.Dup(s, 6)
                        case DUP7 => Bytecode.Dup(s, 7)
                        case DUP8 => Bytecode.Dup(s, 8)
                        case DUP9 => Bytecode.Dup(s, 9)
                        case DUP10 => Bytecode.Dup(s, 10)
                        case DUP11 => Bytecode.Dup(s, 11)
                        case DUP12 => Bytecode.Dup(s, 12)
                        case DUP13 => Bytecode.Dup(s, 13)
                        case DUP14 => Bytecode.Dup(s, 14)
                        case DUP15 => Bytecode.Dup(s, 15)
                        case DUP16 => Bytecode.Dup(s, 16)
                        // 0x90s: Exchange operations
                        case SWAP1 => Bytecode.Swap(s, 1)
                        case SWAP2 => Bytecode.Swap(s, 2)
                        case SWAP3 => Bytecode.Swap(s, 3)
                        case SWAP4 => Bytecode.Swap(s, 4)
                        case SWAP5 => Bytecode.Swap(s, 5)
                        case SWAP6 => Bytecode.Swap(s, 6)
                        case SWAP7 => Bytecode.Swap(s, 7)
                        case SWAP8 => Bytecode.Swap(s, 8)
                        case SWAP9 => Bytecode.Swap(s, 9)
                        case SWAP10 => Bytecode.Swap(s, 10)
                        case SWAP11 => Bytecode.Swap(s, 11)
                        case SWAP12 => Bytecode.Swap(s, 12)
                        case SWAP13 => Bytecode.Swap(s, 13)
                        case SWAP14 => Bytecode.Swap(s, 14)
                        case SWAP15 => Bytecode.Swap(s, 15)
                        case SWAP16 => Bytecode.Swap(s, 16)
                        // 0xA0s: Log operations
                        // else if LOG0 <=case opcode <= LOG4 =>  (s:OKState
                        //   var k =>  case opcode - LOG0) as int; evalLOG(st,k)
                        // 0xf0
                        //  CREATE => Bytecode.evalCREATE(s),
                        //  CALL => Bytecode.evalCALL(s),
                        //  CALLCODE => Bytecode.evalCALLCODE(s),
                        case RETURN => Bytecode.Return(s)
                        // DELEGATECALL => Bytecode.evalDELEGATECALL(s),
                        // CREATE2 => Bytecode.evalCREATE2(s),
                        // STATICCALL => Bytecode.evalSTATICCALL(s),
                        case REVERT => Bytecode.Revert(s)
                        // SELFDESTRUCT := Some((s:OKState) => Bytecode.evalSELFDESTRUCT(s),)
                        case _ => State.INVALID(INVALID_OPCODE)
                        )
            case _ => s
    }

    // A little helper method
    function method Push(s: OKState, k: nat) : State
    requires k > 0 && k <= 32 {
        if s.CodeOperands() >= k
        then
            var bytes := Code.Slice(s.evm.code, (s.evm.pc+1), k);
            assert 0 < |bytes| && |bytes| <= 32;
            Bytecode.Push(s,bytes)
        else
            State.INVALID(STACK_OVERFLOW)
    }
}
