#include <iostream>

#include <a4/application.h>

#include <a4/processor.h>
#include <a4/message.h>

class CopyProcessor : public a4::process::Processor {
public:
    bool _metadata_only;
    bool _salient; // --debug-salient was specified
    bool _fresh_metadata; // encountered new metadata since last event
    
    uint64_t _start_index;
    
    CopyProcessor() : _metadata_only(false), _salient(false),
        _fresh_metadata(true), _start_index(0) {}
    
    virtual shared<a4::io::A4Message> process_new_metadata() {
        _fresh_metadata = true;
        return shared<a4::io::A4Message>();
    }

    virtual void process_message(shared<const a4::io::A4Message> m) {
        if (_metadata_only) {
            skip_to_next_metadata = true;
            return;
        }
    
        // Not a thread safe static but the worst is that we only emit too few
        // events (we only used it to emit a message every 1000 events)
        static size_t i = 0;
        if (i++ < _start_index)
            return;
        
        if (i % 1000 == 0)
            INFO("Copied ", i, " events..");

        // Nested to make logic blindingly clear
        if (_salient) {
            if (_fresh_metadata) {
                write(m);
            }
        } else {
            write(m);
        }
        
        _fresh_metadata = false;
    }
};

class CopyConfiguration : public a4::process::ConfigurationOf<CopyProcessor> {
public:

    bool _metadata_only, _salient;
    uint64_t _start_index;

    CopyConfiguration() : _metadata_only(false), _start_index(0) {}

    void add_options(po::options_description_easy_init opt) {
        opt("metadata-only,M", po::bool_switch(&_metadata_only), "Only copy metadata");
        opt("start-index", po::value(&_start_index), "Start copy from a particular index");
        opt("debug-salient", po::bool_switch(&_salient), "Copy one event per metadata");
    }

    void setup_processor(CopyProcessor& p) {
        if (_start_index) {
            static int processor_count = 0;
            if (processor_count++)
                TERMINATE("--start-index only works with one processor (-t1)");
            p._start_index = _start_index;
        }
        p._metadata_only = _metadata_only;
        p._salient = _salient;
    }
};

int main(int argc, const char* argv[]) {
    return a4::process::a4_main_configuration<CopyConfiguration>(argc, argv);
}
