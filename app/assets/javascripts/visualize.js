$(document).ready( function() {

	var streak = document.getElementById( 'prayer_per_day_average_streak' );
	if (streak){
		longest_streak_width = function( value ) {
			streak.style.width = ( 241/5 ) * value + 'px';
		}

		weekly_prayer_average_streak = function( value, el ) {
			var streak = document.getElementById( el );
			var parent = streak.parentNode;
			streak.style.width = ( 49/5 ) * value + 'px';
			parent.childNodes[ parent.childNodes.length - 2 ].innerHTML = value;
		}

		longest_streak_width( $("#prayer_per_day_average_streak").data("average") );
		weekly_prayer_average_streak( $("#weekly_average_streak_mon").data("average"), 'weekly_average_streak_mon' );
		weekly_prayer_average_streak( $("#weekly_average_streak_tues").data("average"), 'weekly_average_streak_tues' );
		weekly_prayer_average_streak( $("#weekly_average_streak_wed").data("average"), 'weekly_average_streak_wed' );
		weekly_prayer_average_streak( $("#weekly_average_streak_thurs").data("average"), 'weekly_average_streak_thurs' );
		weekly_prayer_average_streak( $("#weekly_average_streak_fri").data("average"), 'weekly_average_streak_fri' );
		weekly_prayer_average_streak( $("#weekly_average_streak_sat").data("average"), 'weekly_average_streak_sat' );
		weekly_prayer_average_streak( $("#weekly_average_streak_sun").data("average"), 'weekly_average_streak_sun' );
	}
	
});
