#include "PluginProcessor.h"
#include "PluginEditor.h"

#include <unistd.h>

ClipperAudioProcessor::ClipperAudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
     : AudioProcessor (BusesProperties()
                     #if ! JucePlugin_IsMidiEffect
                      #if ! JucePlugin_IsSynth
                       .withInput  ("Input",  juce::AudioChannelSet::stereo(), true)
                      #endif
                       .withOutput ("Output", juce::AudioChannelSet::stereo(), true)
                     #endif
                       )
#endif
{
	//unlink("/Users/francesco/Desktop/log.txt");
	
	//log = std::ofstream("/Users/francesco/Desktop/log.txt", std::ios::app);
	
	sampleCallback = [](unsigned int, float) {};
	
	auto totalNumInputChannels = getTotalNumInputChannels();
	for(int channel=0;channel<totalNumInputChannels;channel++)
		clippers.push_back(Clipper());
}

ClipperAudioProcessor::~ClipperAudioProcessor() {}

const juce::String ClipperAudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool ClipperAudioProcessor::acceptsMidi() const
{
   #if JucePlugin_WantsMidiInput
    return true;
   #else
    return false;
   #endif
}

bool ClipperAudioProcessor::producesMidi() const
{
   #if JucePlugin_ProducesMidiOutput
    return true;
   #else
    return false;
   #endif
}

bool ClipperAudioProcessor::isMidiEffect() const
{
   #if JucePlugin_IsMidiEffect
    return true;
   #else
    return false;
   #endif
}

double ClipperAudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int ClipperAudioProcessor::getNumPrograms()
{
    return 1;
}

int ClipperAudioProcessor::getCurrentProgram()
{
    return 0;
}

void ClipperAudioProcessor::setCurrentProgram(int index) {}

const juce::String ClipperAudioProcessor::getProgramName (int index)
{
    return {};
}

void ClipperAudioProcessor::changeProgramName(int index, const juce::String& newName) {}

void ClipperAudioProcessor::prepareToPlay(double sampleRate, int samplesPerBlock)
{
	for(Clipper &clipper : clippers)
		clipper.setSampleRate(sampleRate);
}

void ClipperAudioProcessor::releaseResources() {}

#ifndef JucePlugin_PreferredChannelConfigurations
bool ClipperAudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
{
  #if JucePlugin_IsMidiEffect
    juce::ignoreUnused (layouts);
    return true;
  #else
    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()
     && layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
        return false;

    // This checks if the input layout matches the output layout
   #if ! JucePlugin_IsSynth
    if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())
        return false;
   #endif

    return true;
  #endif
}
#endif

void ClipperAudioProcessor::processBlock(juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
    juce::ScopedNoDenormals noDenormals;
    auto totalNumInputChannels  = getTotalNumInputChannels();
    auto totalNumOutputChannels = getTotalNumOutputChannels();

    for(auto i=totalNumInputChannels;i<totalNumOutputChannels;i++)
        buffer.clear(i, 0, buffer.getNumSamples());

	//std::chrono::steady_clock::time_point start = std::chrono::steady_clock::now();
	if(!bypass)
	{
		for(int channel=0;channel<totalNumInputChannels;channel++)
		{
			auto *channelData = buffer.getWritePointer(channel);
			
			clippers[channel].process(channelData, buffer.getNumSamples());
			
			for(int i=0;i<buffer.getNumSamples();i++)
				sampleCallback(channel, channelData[i]);
		}
	}
	
	//std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
	//log << std::chrono::duration_cast<std::chrono::microseconds>(end-start).count() << std::endl;
}

void ClipperAudioProcessor::setSampleCallback(std::function<void(unsigned int, float)> sampleCallback)
{
	this->sampleCallback = sampleCallback;
}

void ClipperAudioProcessor::setBypass(bool bypass)
{
	this->bypass = bypass;
}

void ClipperAudioProcessor::setL(unsigned int L)
{
	for(Clipper &clipper : clippers)
		clipper.setL(L);
}

void ClipperAudioProcessor::useNewtonRaphson(bool newtonRaphson)
{
	for(Clipper &clipper : clippers)
		clipper.useNewtonRaphson(newtonRaphson);
}

bool ClipperAudioProcessor::hasEditor() const
{
    return true;
}

juce::AudioProcessorEditor* ClipperAudioProcessor::createEditor()
{
    return new ClipperAudioProcessorEditor(*this);
}

void ClipperAudioProcessor::getStateInformation(juce::MemoryBlock& destData) {}

void ClipperAudioProcessor::setStateInformation(const void* data, int sizeInBytes) {}

juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new ClipperAudioProcessor();
}
