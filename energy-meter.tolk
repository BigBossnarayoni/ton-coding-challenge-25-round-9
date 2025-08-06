const MY_WORKCHAIN = BASECHAIN;
const OP_CONSUME = stringCrc32("consume"); // 7fa29d3a
const OP_REFILL = stringCrc32("refill");   // 92b4edc1

var energy: int = 0;

fun consumeEnergy(amount: int) {
    assert(energy >= amount) throw 1005;
    energy -= amount;
}

fun refillEnergy(amount: int) {
    energy += amount;
}

fun routeInternal(`ctx::sender`: slice, `ctx::value`: int, `ctx::fwd_fee`: int, `ctx::body`: slice) {
    var (op: int, _) = `ctx::body`.loadOpAndQueryId();

    if (op == OP_CONSUME) {
        consumeEnergy(15);
        return;
    }

    if (op == OP_REFILL) {
        refillEnergy(30);
        return;
    }

    throw 0xffff;
}

fun main(`ctx::value`: int, inMsgFull: cell, `ctx::body`: slice) {
    var s = inMsgFull.beginParse();
    var flags = s.loadMsgFlags();
    if (isBounced(flags)) { return; }

    var (`ctx::sender`: slice, `ctx::fwd_fee`: int) = s.retrieveCtx(MY_WORKCHAIN);
    routeInternal(`ctx::sender`, `ctx::value`, `ctx::fwd_fee`, `ctx::body`);
}
