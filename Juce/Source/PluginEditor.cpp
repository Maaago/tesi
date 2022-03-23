#include "PluginProcessor.h"
#include "PluginEditor.h"

#include "Clipper.h"

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
	lSlider.setRange(0.0, MAX_L_VALUE, 1.0);
	lSlider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 90, 0);
	lSlider.setTitle("L");
	lSlider.setPopupDisplayEnabled(true, false, this);
	lSlider.setTextValueSuffix("L");
	lSlider.setValue(1.0);
 
	addAndMakeVisible(&lSlider);
	
	lSlider.addListener(this);
	
	//Newton-Raphson toggle button
	newtonRaphson.setButtonText("Usa Newton-Raphson");
	newtonRaphson.setTitle("Usa Newton-Raphson");
	addAndMakeVisible(&newtonRaphson);
	
	newtonRaphson.addListener(this);

	//vout graph
	p.setSampleCallback([this](unsigned int channel, float sample)
	{
		mutex.lock();
		if(channels.size() <= channel)
			channels.resize(channel+1);
		
		channels[channel].push_back(sample);
		
		if(channels[channel].size() > 512)
			channels[channel].pop_front();
		mutex.unlock();
	});
}

ClipperAudioProcessorEditor::~ClipperAudioProcessorEditor() {}

void ClipperAudioProcessorEditor::paint(juce::Graphics& g)
{
    g.fillAll(getLookAndFeel().findColour (juce::ResizableWindow::backgroundColourId));

    g.setColour(juce::Colours::white);
	
	bypass.setBounds(10, 10, getWidth()-20, 20);
	newtonRaphson.setBounds(10, 40, getWidth()-20, 20);
	lSlider.setBounds(10, 70, getWidth()-20, 50);
	
	mutex.lock();
	for(int i=0;i<channels.size();i++)
	{
		unsigned int height = 10;
		unsigned int width = getWidth()-20;
		
		unsigned int xMargin = 10;
		unsigned int yMargin = 90;
		
		unsigned int currentX = 1;
		
		std::list<float> &buffer = channels[i];
		
		std::list<float>::iterator it1, it2;
		for(it1=buffer.begin(),it2=++it1;it2!=buffer.end();++it1,++it2)
		{
			float x1 = xMargin+static_cast<float>(juce::jmap<unsigned long>(currentX-1, 0, buffer.size()-1, 0, width));
			float x2 = xMargin+static_cast<float>(juce::jmap<unsigned long>(currentX, 0, buffer.size()-1, 0, width));

			float y1 = yMargin+juce::jmap(*it1, 0.0f, 1.0f, static_cast<float>(height), 0.0f);
			float y2 = yMargin+juce::jmap(*it2, 0.0f, 1.0f, static_cast<float>(height), 0.0f);

			g.drawLine ({ x1, y1, x2, y2 });
			
			yMargin += height+10;
			currentX++;
		}
	}
	mutex.unlock();
}

void ClipperAudioProcessorEditor::resized() {}

void ClipperAudioProcessorEditor::sliderValueChanged(juce::Slider* slider)
{
	audioProcessor.setL(lSlider.getValue());
}

void ClipperAudioProcessorEditor::buttonStateChanged(juce::Button *button)
{
	if(button == &bypass)
		audioProcessor.setBypass(button->getToggleState());
	else
		audioProcessor.useNewtonRaphson(button->getToggleState());
}
