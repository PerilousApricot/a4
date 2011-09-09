#include <iostream>

#include "a4/proto/io/A4Stream.pb.h"
#include "a4/output_stream.h"
#include "a4/input_stream.h"

using namespace std;
using namespace a4::io;

int main(int argc, char ** argv) {
    {
        uint32_t clsid = TestEvent::kCLASSIDFieldNumber;
        uint32_t clsid_m = TestMetaData::kCLASSIDFieldNumber;
        A4OutputStream w("test.a4", "TestEvent", clsid, clsid_m);

        const int N = 1000;
        TestEvent e;
        for(int i = 0; i < N; i++) {
            e.set_event_number(i);
            w.write(e);
        }
        TestMetaData m;
        m.set_meta_data(N);
        w.metadata(m);
    }
    {
        A4InputStream r("test.a4");
        bool running = true;

        int cnt = 0;
        while (r.is_good()) {
            ReadResult rr = r.next();
            if (rr.class_id == TestEvent::kCLASSIDFieldNumber) {
                auto te = dynamic_shared_cast<TestEvent>(rr.object);
                assert(cnt++ == te->event_number());
            } else if (rr.class_id == TestMetaData::kCLASSIDFieldNumber) {
                auto meta = dynamic_shared_cast<TestMetaData>(rr.object);
                assert(cnt == meta->meta_data());
            } else if (rr == READ_ERROR) throw "AJS";
        }
    }
}