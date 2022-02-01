/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#pragma once

#include <JuceHeader.h>
#include "PluginProcessor.h"

//==============================================================================
/**
*/
class ClipperAudioProcessorEditor  : public juce::AudioProcessorEditor, private juce::ToggleButton::Listener, private juce::Slider::Listener
{
public:
    ClipperAudioProcessorEditor(ClipperAudioProcessor&);
    ~ClipperAudioProcessorEditor() override;

    //==============================================================================
    void paint(juce::Graphics&) override;
    void resized() override;

private:
    // This reference is provided as a quick way for your editor to
    // access the processor object that created it.
    ClipperAudioProcessor& audioProcessor;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (ClipperAudioProcessorEditor)
	
	juce::ToggleButton enable;
	juce::Slider gain;
	
	void sliderValueChanged(juce::Slider *slider) override;
	void buttonStateChanged(juce::Button *button) override;
	void buttonClicked(juce::Button *) override {};
};
