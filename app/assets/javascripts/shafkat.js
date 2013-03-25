// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

var colorTable = new Object();
colorTable[ 'Fajr' ] = '#FD5737';
colorTable[ 'Duhr' ] = '#F6C546';
colorTable[ 'Asr' ] = '#2BA6AE';
colorTable[ 'Maghrib' ] = '#9C5193';
colorTable[ 'Isha' ] = '#1B2723';
generateCircle = function( size, color, innerText, insertInto )
{
var circle = document.createElement( 'div' );
circle.setAttribute( 'class', 'circle' );
var textField = document.createElement( 'p' );
textField.width = '25px';
textField.innerHTML = innerText;
circle.appendChild( textField );
return circle;
}
prayersPerWeek = function()
{
var container = document.getElementById( 'prayers_per_week' ),
table = document.createElement( 'table' ),
trow = document.createElement( 'tr' ),
count;
for( count = 0; count < 5; count++ )
{
var td = document.createElement( 'td' );
var circle = generateCircle( 5, 5, 5, 5 );
td.appendChild( circle );
td.appendChild( title )
trow.appendChild( td );
}
table.setAttribute( 'align', 'center' );
table.appendChild( trow );
container.appendChild( table );
}
changeGraph = function( value )
{
var table1 = document.getElementById( 'table_1' );
var table2 = document.getElementById( 'table_2' );
switch( value )
{
case 1:
table1.setAttribute( 'style', 'display: visible;' );
table2.setAttribute( 'style', 'display: none;' );
break;
case 2:
table1.setAttribute( 'style', 'display: none;' );
table2.setAttribute( 'style', 'display: visible;' );
break;
}
}


weekly_prayer_average_streak = function( value, el )
{
var streak = document.getElementById( el );
var parent = streak.parentNode;
streak.style.width = ( 49/5 ) * value + 'px';
parent.childNodes[ parent.childNodes.length - 2 ].innerHTML = value;
}

