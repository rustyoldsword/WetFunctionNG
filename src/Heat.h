#pragma once

#include "Settings.h"

namespace WFNG::Heat
{
	// Loads SunHelm's heat-source lists when SunHelmSurvival.esp is installed and Survival Mode's warm-up list when
	// its plugin is loaded (data loaded and every game load).
	void Refresh();

	// Main thread. True while the actor stands within reach of a fire: SunHelm's and Survival Mode's lists when
	// present, plus campfires, fireplaces, braziers and forges recognised by their model name.
	bool IsNear(RE::Actor* a_actor, const Settings& a_settings);

	// Number of base objects taken from SunHelm; any thread.
	std::size_t SunHelmSources();

	// Number of base objects taken from Survival Mode's warm-up list; any thread.
	std::size_t SurvivalSources();
}
