#include "Manager.h"
#include "Settings.h"

// Plain C exports for other SKSE plugins (Vitals HUD reads these through GetProcAddress). Any thread: they only
// read the lock-free player gauge and settings floats.
extern "C"
{
	struct WFNG_PlayerGauge
	{
		std::uint32_t size;    // caller sets sizeof(WFNG_PlayerGauge); fields past it are not written
		bool          active;  // the player is managed and the game is running
		float         wetness;
		float         rate;    // wetness points per game hour, negative while drying
		float         dry;     // thresholds and cap from the settings
		float         sweat;
		float         soaked;
		float         cap;
	};

	__declspec(dllexport) bool WFNG_GetPlayerGauge(WFNG_PlayerGauge* a_out)
	{
		if (!a_out || a_out->size < sizeof(WFNG_PlayerGauge)) {
			return false;
		}
		const auto  gauge = WFNG::Manager::Get().PlayerGauge();
		const auto& settings = WFNG::Settings::Get();
		a_out->active = gauge.active && settings.bPlayerEnabled;
		a_out->wetness = gauge.wetness;
		a_out->rate = gauge.rate;
		a_out->dry = settings.fWetnessDry;
		a_out->sweat = settings.fWetnessStart;
		a_out->soaked = settings.fWetnessSoaked;
		a_out->cap = settings.fWetnessCap;
		return true;
	}
}
