/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
ClipperAudioProcessorEditor::ClipperAudioProcessorEditor(ClipperAudioProcessor& p)
    : AudioProcessorEditor (&p), audioProcessor (p)
{
    // Make sure that before the constructor has finished, you've set the
    // editor's size to whatever you need it to be.
    setSize(200, 200);
	/*
	// these define the parameters of our slider object
	gain.setSliderStyle(juce::Slider::RotaryHorizontalVerticalDrag);
	gain.setRange(0.0, 1.0);
	gain.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 90, 0);
	gain.setTitle("Gain");
	gain.setPopupDisplayEnabled(true, false, this);
	gain.setTextValueSuffix("Gain");
	gain.setValue(1.0);
 
	// this function adds the slider to the editor
	addAndMakeVisible(&gain);
	
	gain.addListener(this);
	*/
	
	//"Enable" toggle button
	enable.setButtonText("Enable");
	enable.setTitle("Enable");
	addAndMakeVisible(&enable);
	
	enable.addListener(this);
}

ClipperAudioProcessorEditor::~ClipperAudioProcessorEditor()
{
}

//==============================================================================
void ClipperAudioProcessorEditor::paint(juce::Graphics& g)
{
    // (Our component is opaque, so we must completely fill the background with a solid colour)
    g.fillAll(getLookAndFeel().findColour (juce::ResizableWindow::backgroundColourId));

    g.setColour(juce::Colours::white);
	
	//gain.setBounds(10, 10, getWidth()-20, getHeight()-20);
	enable.setBounds(10, 10, getWidth()-20, getHeight()-20);
}

void ClipperAudioProcessorEditor::resized()
{
    // This is generally where you'll want to lay out the positions of any
    // subcomponents in your editor..
	gain.setBounds(40, 30, 20, getHeight() - 60);
}

void ClipperAudioProcessorEditor::sliderValueChanged(juce::Slider* slider)
{
	audioProcessor.gain = gain.getValue();
}

void ClipperAudioProcessorEditor::buttonStateChanged(juce::Button *button)
{
	if(button->getToggleState())
		audioProcessor.enable();
	else
		audioProcessor.disable();
}
