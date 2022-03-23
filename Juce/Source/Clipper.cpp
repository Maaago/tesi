//
//  Clipper.cpp
//  clipper - VST3
//
//  Created by Francesco Magoga
//

#include "Clipper.h"

#include <cmath>

#include <unistd.h>

#include <juce_dsp/maths/juce_FastMathApproximations.h>

#define THRESHOLD 1e-4				//in Volts
#define MAX_ITERATIONS 250

using juce_math = juce::dsp::FastMathApproximations;

Clipper::Clipper()
{
	diodeA.alpha = 1/(2*23e-3);         //23mV
	diodeA.beta = 2.52e-9;              //2.52nA
	diodeB.alpha = 1/(2*23e-3);         //23mV
	diodeB.beta = 2.52e-9;              //2.52nA
	
	Rin = 1e3;                          //1kOhm
	C = 100e-9;                         //100nF
	
	L = 0;								//Valore iniziale di L
	
	h = 1e-5;
	
	lastFPOutput = 0;
	
	inputGain = 0.0f;
	
	newtonRaphson = false;
}

Clipper::~Clipper()
{
	
}

void Clipper::setL(unsigned int L)
{
	this->L = L;
}

void Clipper::setSampleRate(unsigned int sampleRate)
{
	this->sampleRate = sampleRate;
	
	sampleRate = 192000;
	T = 1.0f/sampleRate;
}

void Clipper::useNewtonRaphson(bool newtonRaphson)
{
	this->newtonRaphson = newtonRaphson;
}

void Clipper::process(float *buffer, size_t size)
{
	for(int sample=0;sample<size;sample++)
		buffer[sample] = capacitorVoltage(buffer[sample]);
}

float Clipper::capacitorVoltage(float vin)
{
	if(inputGain < 1.0f)
	{
		vin *= inputGain;
		
		inputGain += 0.0000001f;
		
		if(inputGain > 0.000001f)
			inputGain = 1.0f;
	}
	
	float vb = fixedPoint(lastFPOutput, vin);
	float va = std::asinh(diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*vb))/diodeA.alpha;
	
	if(isnan(vb))
	{
		vb = vin;
		va = 0;
	}
	
	lastFPOutput = vb;
	
	//if(log != nullptr)
	//	*log << vin << std::endl << vb << std::endl << std::endl;
	
	return va+vb;
}

float Clipper::fixedPoint(float lastFPOutput, float vin)
{
	float vb = lastFPOutput;
	float oldVb = vb+1;
	
	unsigned int iteration = 0;
	while(std::abs(vb-oldVb) > THRESHOLD && iteration < MAX_ITERATIONS)
	{
		oldVb = vb;
		
		vb = vb-summation(vb, vin)*(vb-discretized(vb, vin, lastFPOutput));
		
		iteration++;
	}
	
	return vb;
}

float Clipper::discretized(float vb, float vin, float oldVb)
{
	//part1
	float arg = diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*vb);
	float squareRoot = diodeA.alpha*diodeA.beta*std::sqrt(1+std::pow(arg, 2));
	float denominator = diodeB.alpha*diodeB.beta*juce_math::cosh(diodeB.alpha*vb)+squareRoot;
	float part1 = squareRoot/denominator;

	//part2
	float va = std::asinh(diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*vb))/diodeA.alpha;
	float voltagesPart = (vin-va-vb)/Rin;
	float diodePart = 2.0f*diodeB.beta*juce_math::sinh(diodeB.alpha*vb);
	float part2 = voltagesPart-diodePart;

	return h * part1 * part2 / C + oldVb;
}

float Clipper::jacobian(float vb, float vin)
{
	float sqrtArg = 1+std::pow(diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*vb), 2);
	
	// derivata di f
	float phiNum = diodeB.alpha*diodeB.beta*juce_math::cosh(diodeB.alpha*vb);
	float phiDen = diodeA.alpha*diodeA.beta*std::sqrt(sqrtArg);
	float phi = phiNum/phiDen;
	
	float derSqrtNum = juce_math::sinh(diodeB.alpha*vb)*juce_math::cosh(diodeB.alpha*vb);
	float derSqrt = diodeB.alpha*std::pow(diodeB.beta, 2)/std::pow(diodeA.beta, 2)*derSqrtNum/std::sqrt(sqrtArg);
	float psi = diodeB.alpha*juce_math::sinh(diodeB.alpha*vb)*std::sqrt(sqrtArg)-juce_math::cosh(diodeB.alpha*vb)*derSqrt;

	float derPhiDen = diodeA.alpha*diodeA.beta*sqrtArg;
	float derPhi = diodeB.alpha*diodeB.beta*psi/derPhiDen;
	
	float fDer = -derPhi/std::pow(phi, 2);
	
	// derivata di g
	float voltagesPartDerDen = diodeA.alpha*diodeA.beta*std::sqrt(sqrtArg);
	float voltagesPartDer = -diodeB.alpha*diodeB.beta*juce_math::cosh(diodeB.alpha*vb)/voltagesPartDerDen-1;
	
	float gDer = voltagesPartDer/Rin-2*diodeB.alpha*diodeB.beta*juce_math::cosh(diodeB.alpha*vb);
	
	// f
	float squareRoot = diodeA.alpha*diodeA.beta*std::sqrt(sqrtArg);
	float denominator = diodeB.alpha*diodeB.beta*juce_math::cosh(diodeB.alpha*vb)+squareRoot;
	float f = squareRoot/denominator;
	
	// g
	float va = std::asinh(diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*vb))/diodeA.alpha;
	float voltagesPart = (vin-va-vb)/Rin;
	float diodePart = 2.0f*diodeB.beta*juce_math::sinh(diodeB.alpha*vb);
	float g = voltagesPart-diodePart;
	
	return h*(fDer*g+f*gDer)/C;
}

float Clipper::summation(float vb, float vin)
{
	//Invece che calcolare la potenza ad ogni iterazione del ciclo viene moltiplicato il valore dell'iterazione precedente per j
	
	float sum = 1.0f;
	float power = 1.0f;
	
	float jc;
	if(L > 0 || newtonRaphson)
		jc = jacobian(vb, vin);
	
	if(newtonRaphson)
		sum = 1.0f/(1.0f-jc);
	else
		for(int l=1;l<=L;l++)
		{
			power *= jc;
			
			sum += power;
		}
	
	return sum;
}
