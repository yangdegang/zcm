include("../build/types/test_package.jl");

import test_package:packaged_t

using ZCM

numReceived = 0
handler = function(rbuf, channel::String, msg::test_package.packaged_t)
    println("Received message on channel: ", channel)
    global numReceived
    @assert (((numReceived % 2) == 0) == msg.packaged) "Received message with incorrect packaged flag"
    numReceived = numReceived + 1
end

zcm = Zcm("inproc")
if (!good(zcm))
    println("Unable to initialize zcm");
    exit()
end

sub = subscribe(zcm, "EXAMPLE", handler, test_package.packaged_t)

msg = test_package.packaged_t()

start(zcm)

msg.packaged = true;
publish(zcm, "EXAMPLE", msg)
msg.packaged = false;
publish(zcm, "EXAMPLE", msg)
msg.packaged = true;
publish(zcm, "EXAMPLE", msg)

sleep(0.5)
stop(zcm)

unsubscribe(zcm, sub)

@assert (numReceived == 3) "Didn't receive proper number of messages"
println("Success!")
