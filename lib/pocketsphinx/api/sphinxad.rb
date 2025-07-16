module Pocketsphinx
  module API
    module SphinxAD
      extend FFI::Library
      
      # SphinxAD library is not available in PocketSphinx v5
      # Audio device functionality may need to be handled differently
      # For now, we'll create stub implementations to maintain API compatibility
      
      def self.ad_open_dev(device, sample_rate)
        warn "SphinxAD not available in PocketSphinx v5 - audio device functionality disabled"
        nil
      end
      
      def self.ad_start_rec(ad)
        warn "SphinxAD not available in PocketSphinx v5 - audio device functionality disabled"
        -1
      end
      
      def self.ad_stop_rec(ad)
        warn "SphinxAD not available in PocketSphinx v5 - audio device functionality disabled"
        -1
      end
      
      def self.ad_read(ad, buffer, max_samples)
        warn "SphinxAD not available in PocketSphinx v5 - audio device functionality disabled"
        -1
      end
      
      def self.ad_close(ad)
        warn "SphinxAD not available in PocketSphinx v5 - audio device functionality disabled"
      end
    end
  end
end
