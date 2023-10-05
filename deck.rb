#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'dry-cli'
end

module StreamDeck
  module CLI
    module Commands
      extend Dry::CLI::Registry

      class Version < Dry::CLI::Command
        desc 'Print version'

        def call(*)
          puts '1.0.0'
        end
      end

      module Camera
        ZOOM_STEP = 10
        def self.get(attribute)
          response = `v4l2-ctl -d 1 --get-ctrl=#{attribute}`
          response.split(':')[1].to_i
        end

        def self.set(attribute, value)
          `v4l2-ctl -d 1 --set-ctrl=#{attribute}=#{value}`
        end

        class IncreaseZoom < Dry::CLI::Command
          desc 'Increase the zoom of the camera'

          def call(*)
            Camera.set(:zoom_absolute, Camera.get(:zoom_absolute) + ZOOM_STEP)
          end
        end

        class DecreaseZoom < Dry::CLI::Command
          desc 'Decrease the zoom of the camera'

          def call(*)
            Camera.set(:zoom_absolute, Camera.get(:zoom_absolute) - ZOOM_STEP)
          end
        end

        class ZoomOff < Dry::CLI::Command
          desc 'Reset zoom of the camera'

          def call(*)
            Camera.set(:zoom_absolute, 100)
          end
        end
      end

      register 'version', Version, aliases: ['v', '-v', '--version']
      register 'camera increase_zoom', Camera::IncreaseZoom
      register 'camera decrease_zoom', Camera::DecreaseZoom
      register 'camera zoom_off', Camera::ZoomOff
    end
  end
end

Dry::CLI.new(StreamDeck::CLI::Commands).call
