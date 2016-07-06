package org.yakindu.sct.generator.cpp.arduino

import com.google.inject.Inject
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sgraph.Statechart
import org.eclipse.xtext.generator.IFileSystemAccess
import org.yakindu.sct.model.sgen.GeneratorEntry

class AbstractTimer {

	@Inject
	extension Naming

	def generateAbstractTimer(ExecutionFlow flow, Statechart sc, IFileSystemAccess fsa, GeneratorEntry entry) {
		fsa.generateFile(abstractTimer.cpp, flow.generateContents(entry))
	}

	def private generateContents(ExecutionFlow it, GeneratorEntry entry) '''
		#include "«abstractTimer.h»"
		
		volatile bool runCycleFlag = false;
		
		/* period in milliseconds */
		«abstractTimer»::«abstractTimer»(«statemachineInterface»* statemachine, «hardwareConnector»* hardware,
				unsigned short maxParallelTimeEvents, unsigned int period) {
			this->statemachine = statemachine;
			this->hardware = hardware;
			this->maxParallelTimeEvents = maxParallelTimeEvents;
			this->period = period;
		
			this->events = new «timeEvent»[this->maxParallelTimeEvents];
			for (unsigned short i = 0; i < this->maxParallelTimeEvents; i++) {
				this->events[i].eventId = NULL;
			}
		}
		
		«abstractTimer»::~«abstractTimer»() {
			delete this->events;
		}
		
		void «abstractTimer»::start() {
			this->hardware->init();
			this->statemachine->init();
			this->statemachine->enter();
			this->init();
		}
		
		void «abstractTimer»::setTimer(«timedStatemachineInterface»* timedStatemachine, sc_eventid eventId, sc_integer duration,
				sc_boolean isPeriodic) {
			for (unsigned short i = 0; i < this->maxParallelTimeEvents; i++) {
				if (events[i].eventId == NULL) {
					events[i].timedStatemachine = timedStatemachine;
					events[i].eventId = eventId;
					events[i].overflows = duration / this->period;
					events[i].periodic = isPeriodic;
					events[i].overflowCounter = 0;
					events[i].eventRaised = false;
					break;
				}
			}
		}
		
		void «abstractTimer»::unsetTimer(«timedStatemachineInterface»* timedStatemachine, sc_eventid eventId) {
			for (unsigned short i = 0; i < this->maxParallelTimeEvents; i++) {
				if (events[i].eventId == eventId) {
					events[i].eventId = NULL;
					break;
				}
			}
		}
		
		void «abstractTimer»::runCycle() {
			if (runCycleFlag) {
				this->raiseTimeEvents();
				this->statemachine->runCycle();
				this->hardware->runCycle();
				runCycleFlag = false;
			}
			this->sleep();
		}
		
		void «abstractTimer»::raiseTimeEvents() {
			for (unsigned short i = 0; i < this->maxParallelTimeEvents; i++) {
				if (events[i].eventId == NULL) {
					continue;
				}
		
				if ((events[i].overflowCounter >= events[i].overflows) && !events[i].eventRaised) {
					events[i].timedStatemachine->raiseTimeEvent(events[i].eventId);
					events[i].overflowCounter = 0;
		
					if (!events[i].periodic) {
						events[i].eventRaised = true;
					}
				}
		
				events[i].overflowCounter++;
			}
		}
		
		void «abstractTimer»::cancel() {
			this->stop();
		}
	'''
	
}