<html>

	<head>
		<title>API Statistics</title>
		<cfoutput>
			<cfset templatePath = "cfapi/assets" />
			<link rel="shortcut icon" href="/#EncodeForHTML(templatePath)#/img/favicon_statistics.ico" type="image/x-icon" />
			<script src="/#EncodeForHTML(templatePath)#/js/jquery.min.js"></script>
			<script src="/#EncodeForHTML(templatePath)#/js/jquery-ui.min.js"></script>
			<script src="/#EncodeForHTML(templatePath)#/js/include.js"></script>
			<link rel="stylesheet" href="/#EncodeForHTML(templatePath)#/css/include.css" />
			<link rel="stylesheet" href="/#EncodeForHTML(templatePath)#/css/jquery-ui.theme.min.css" />
		</cfoutput>
		
		<script>
		function loadStatisticsByType() {
			var statistics_type = $('input[type=radio][name=statistics_selector]:checked').val();
			$('#result_div').html("<img src='/assets/img/progress.gif'>");
			var url = "";
			
			if(statistics_type === "usage") {
				url = "api_usage.cfm";
			} else if(statistics_type === "implementation") {
				url = "api_implementation.cfm";
			}
			if(statistics_type !== null) {
				$.get(url,
					function (data, status) {
						$('#result_div').html(data);
					}
				);
			}
		}
		</script>
	
		
	
	</head>
	
	<body>
	
		<div id="selector">
			<label for="statistics_usage">API Usage</label>
			<input class="checkboxradio" type="radio" group="statistics_selector" name="statistics_selector" id="statistics_usage" value="usage" checked />
			<label for="statistics_implementation">API Implementation</label>
			<input class="checkboxradio" type="radio" group="statistics_selector" name="statistics_selector" id="statistics_implementation" value="implementation" />
		</div>
		
		<div id="result_div"></div>
		
	</body>
	
	
</html>


<script>
	$(function() {
		loadDefault();
		loadStatisticsByType();
		
		$('input[type=radio][name=statistics_selector]').change(function() {
			loadStatisticsByType();
		});
	});
</script>