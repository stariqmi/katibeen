$("#modal").modal('show');

<% if @redirect_to_dash %>
window.location = '<%=@redirect_to_dash%>';
<% end %>

$("#welcomeModal").modal('hide');

<% if @result2.nil? %>
	document.getElementById('modal-body').innerHTML = "<%= @result %>";
<% else %>
	document.getElementById('modal-body').innerHTML = "<%= @result %> <br> <%= @result2 %>";
<% end %>

document.getElementById('modal-title').innerHTML = "<%= @title%>";

<% if @redirect %>
	setTimeout(function(){window.location = '<%=@redirect%>';},3000);
<% else %>
	setTimeout(function(){ window.close(); },3000);
<% end %>
