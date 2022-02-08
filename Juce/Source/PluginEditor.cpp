#include "PluginProcessor.h"
#include "PluginEditor.h"

ClipperAudioProcessorEditor::ClipperAudioProcessorEditor(ClipperAudioProcessor& p)
    : AudioProcessorEditor (&p), audioProcessor (p)
{
	setSize(200, 200);

	//Bypass toggle button
	bypass.setButtonText("Bypass");
	bypass.setTitle("Bypass");
	addAndMakeVisible(&bypass);
	
	bypass.addListener(this);
	
	//L parameter slider
	lSlider.setSliderStyle(juce::Slider::LinearHorizontal);
	lSlider.setRange(0.0, 500.0, 1.0);
	lSlider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 90, 0);
	lSlider.setTitle("L");
	lSlider.setPopupDisplayEnabled(true, false, this);
	lSlider.setTextValueSuffix("L");
	lSlider.setValue(1.0);
 
	//this function adds the slider to the editor
	addAndMakeVisible(&lSlider);
	
	lSlider.addListener(this);
}

ClipperAudioProcessorEditor::~ClipperAudioProcessorEditor() {}

void ClipperAudioProcessorEditor::paint(juce::Graphics& g)
{
    g.fillAll(getLookAndFeel().findColour (juce::ResizableWindow::backgroundColourId));

    g.setColour(juce::Colours::white);
	
	bypass.setBounds(10, 10, getWidth()-20, 20);
	lSlider.setBounds(10, 40, getWidth()-20, 50);
}

void ClipperAudioProcessorEditor::resized() {}

void ClipperAudioProcessorEditor::sliderValueChanged(juce::Slider* slider)
{
	audioProcessor.setL(lSlider.getValue());
}

void ClipperAudioProcessorEditor::buttonStateChanged(juce::Button *button)
{
	audioProcessor.setBypass(button->getToggleState());
}
