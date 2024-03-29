#pragma once

#include <list>
#include <vector>
#include <mutex>

#include <JuceHeader.h>
#include "PluginProcessor.h"

class ClipperAudioProcessorEditor  : public juce::AudioProcessorEditor, private juce::ToggleButton::Listener, private juce::Slider::Listener
{
public:
    ClipperAudioProcessorEditor(ClipperAudioProcessor&);
    ~ClipperAudioProcessorEditor() override;

    void paint(juce::Graphics&) override;
    void resized() override;

private:
    ClipperAudioProcessor& audioProcessor;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (ClipperAudioProcessorEditor)
	
	juce::ToggleButton bypass, newtonRaphson;
	juce::Slider lSlider;
	
	void sliderValueChanged(juce::Slider *slider) override;
	void buttonStateChanged(juce::Button *button) override;
	void buttonClicked(juce::Button *) override {};
	
	std::vector<std::list<float>> channels;
	
	std::mutex mutex;
};
