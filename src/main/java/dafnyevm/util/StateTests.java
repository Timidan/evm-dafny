/**
 * A test runner for executing the <code>GeneralStateTests</code> provided as
 * part of the Ethereum Reference tests (see
 * <a href="https://github.com/ethereum/tests/">here</a>). The test runner works
 * by combining two pieces of information for each tests:
 *
 * <ul>
 * <li><b>Test Fixture</b>. This is the (filled) tests provided by the Ethereum
 * reference tests, and accessible from this repository within the
 * <code>fixtures/</code> directory (which is a submodule).</li>
 * <li><b>Internal State</b>. This internal state information generated from
 * running the corresponding fixture using an existing tool, such as Geth's
 * `evm` command-line tool. This internal state supplements the test fixture
 * which information about the EVM internals during execution of the test (e.g.
 * the value of the stack or memory after executing each bytecode). This data is
 * stored within the <code>tests/</code> directory, where the layout follows
 * that of the <code>fixtures</code> directory.</li>
 * </ul>
 *
 * This test runner is "driven" by the test files stored within the
 * <code>tests/</code>. That means a test is only run when there is a
 * corresponding entry in this file.
 *
 * @author David J. Pearce
 *
 */
package dafnyevm.util;

import java.math.BigInteger;
import java.util.Map;

import dafnyevm.DafnyEvm;
import dafnyevm.DafnyEvm.Tracer;
import evmtools.core.Environment;
import evmtools.core.Transaction;
import evmtools.core.WorldState;

/**
 * Various utilities for managing state tests, such as converting from JSON into
 * formats appropriate for the Dafny EVM.
 *
 * @author David J. Pearce
 *
 */
public class StateTests {

    /**
     * Run a specific state test instance.
     *
     * @param name   Name of the test to run
     * @param env    Block environment for the test
     * @param state  World state for the test
     * @param tx     Transaction details of the test.
     * @param tracer Tracer to use during execution.
     */
    public static void runInstance(String name, Environment env, WorldState state, Transaction tx, Tracer tracer) {
        DafnyEvm.BlockInfo blk = toBlockInfo(env);
        // FIXME: following contains a workaround for an issue with the trace output,
        // whereby traces are used the _block's gas limit_ rather than the
        // _transaction's gas limit_. #245
        DafnyEvm evm = new DafnyEvm().tracer(tracer).gasPrice(tx.gasPrice).blockInfo(blk).to(tx.to)
                .sender(tx.sender)
                .origin(tx.sender).gas(blk.gasLimit).value(tx.value).data(tx.data);
        // Set the world state
        configureWorldState(evm,state);
        // Run call or create
        if (tx.to != null) {
            evm.call();
        } else {
            evm.create();
        }
    }

    /**
     * Construct the necessary block environment from the test's environmental
     * parameters.
     *
     * @param env
     * @return
     */
    public static DafnyEvm.BlockInfo toBlockInfo(Environment env) {
        DafnyEvm.BlockInfo info = new DafnyEvm.BlockInfo();
        info = info.coinBase(env.currentCoinbase);
        info = info.timeStamp(env.currentTimestamp);
        // NOTE: following currently replicates what Geth does (which default's to
        // Ganache's ChainID). At some point, we'll need to fix this.
        info = info.chainID(0x539);
        // NOTE: following is commented out whilst trace data is generated using the
        // "evm" tool directly, as this does not allow a block number other than zero.
        // info = info.number(env.currentNumber);
        info = info.number(0);
        info = info.difficulty(env.currentDifficulty);
        info = info.gasLimit(env.currentGasLimit);
        return info;
    }

    /**
     * Configure a DafnyEVM with the current world state.
     *
     * @param st
     * @param evm
     * @return
     */
    public static void configureWorldState(DafnyEvm evm, WorldState ws) {
        // Initialise world statew
        for (Map.Entry<BigInteger, evmtools.core.Account> e : ws.entrySet()) {
            evmtools.core.Account acct = e.getValue();
            evm.create(e.getKey(), acct.nonce, acct.balance, acct.storage, acct.code);
        }
    }
}
