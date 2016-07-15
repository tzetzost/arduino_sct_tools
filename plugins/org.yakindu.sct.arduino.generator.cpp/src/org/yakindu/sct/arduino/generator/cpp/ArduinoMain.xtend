/**
 * Copyright (c) 2016 by Lothar Wendehals.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.yakindu.sct.arduino.generator.cpp

import com.google.inject.Inject
import org.eclipse.xtext.generator.IFileSystemAccess
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Statechart

class ArduinoMain {

	@Inject extension Naming
	@Inject extension GenmodelEntriesExtension

	def generateMain(ExecutionFlow it, GeneratorEntry entry, IFileSystemAccess fsa) {
		fsa.generateFile(main.cpp, generateContents(entry))
	}

	def private generateContents(ExecutionFlow it, GeneratorEntry entry) '''
		«header»
		
		#include <Arduino.h>
		#include "«module.h»"
		#include "«IF isSoftwareTimer(entry)»«softwareTimer.h»«ELSE»«atMega168_328Timer.h»«ENDIF»"
		#include "«entry.userSrcFolderRelativeToSrcGen»«module.connector.h»"
		
		#define PERIOD 10
		#define MAX_PARALLEL_TIMERS «MaxParallelTimersCalculator::calculate(it.sourceElement as Statechart)»
		
		«module»* statemachine;
		«module.connector»* connector;
		«IF isSoftwareTimer(entry)»«softwareTimer»«ELSE»«atMega168_328Timer»«ENDIF»* timer;
		
		void setup() {
			statemachine = new «module»();
			connector = new «module.connector»(statemachine);
			timer = new «IF isSoftwareTimer(entry)»«softwareTimer»«ELSE»«atMega168_328Timer»«ENDIF»(statemachine, connector, MAX_PARALLEL_TIMERS, PERIOD);
		
			statemachine->setTimer(timer);
			timer->start();
		}
		
		void loop() {
			timer->runCycle();
		}
	'''

}