(function ()
	{
		///////////////////////////////////////////////////////////////////////////////////////////////////////
		// enumerations section
	
		var nativeCommands = 
		{
			Log: "log",
			Close: "close",
			Expand: "expand",
			SetExpandProperties: "setExpandProperties",
			Open: "open",
			UpdateGeoLocation: "updateGeoLocation"
		};
	
	 	var states = 
 		{
    		Loading: "loading",
    		Default: "default",
			Expanded: "expanded",
			Hidden: "hidden",
		};
		
		var placementTypes = 
		{
			Inline: "inline",
			Interstitial: "interstitial",
		};

  		var events = 
		{
			Error: "error",
			Info: "info",
			Ready: "ready",
			StateChange: "stateChange",
			ViewableChange: "viewableChange",
		};
	
		///////////////////////////////////////////////////////////////////////////////////////////////////////
		// utils section

		var expandPropertiesCheckers =
		{
			width: function(v) { return !isNaN(v) && v >= 0; },
			height: function(v) { return !isNaN(v) && v >= 0; },
			useCustomClose: function(v) { return (typeof v === "boolean"); },
		};
 
		ES_CHECK_PARAMETERS = function(parameters, checkers, func)
	  	{
			if (parameters === null) 
			{
				ES_LOG_ERROR("Passing empty parameters for function \"" + func + "\"", func);
				return false;
			}
			
			for (var parameter in parameters) 
			{
				var checker = checkers[parameter];
				var value = parameters[parameter];
				if (checker && !checker(value)) 
				{
					ES_LOG_ERROR("Invalid parameter \"" + parameter +"\" value for function \"" + func + "\"", func);
					return false;
				}
			}
			return true;
    	};

		ES_CHECK_ENUMERATION = function(value, enumeration, func)
	  	{
			if (value === null) 
			{
				utils.ES_LOG_ERROR("Passing empty enumeration value for function \"" + func + "\"", func);
				return false;
			}
			for (var e in enumeration) 
			{
				if (enumeration[e] === value) 
				{
					return true;
				}
			}
			ES_LOG_ERROR("Can't find enumeration value \"" + value + "\" value for function \"" + func + "\"", func);
			return false;
    	};

		ES_LOG_INFO = function(message, action)
		{
			mraid.fireInfoEvent(message, action);
			return executeNativeCall(nativeCommands.Log, "type", "info", "message", message, "action", action);
		};
		
		ES_LOG_ERROR = function(message, action)
		{
			mraid.fireErrorEvent(message, action);
			return executeNativeCall(nativeCommands.Log, "type", "error", "message", message, "action", action);
		};
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////
		// Objective-C code execute section
 
		var executeNativeCallQueue = [];
		var executeNativeCallIsActive = false;

		executeNativeCall = function(command)
		{
			if (!ES_CHECK_ENUMERATION(command, nativeCommands, "executeNativeCall"))
			{
				return false;
			}
			
			var url = "mraid://" + command;
			var args = "";
			for (var i = 1; i < arguments.length; i += 2)
			{
				var key = arguments[i];
				var value = arguments[i + 1];
				if ((key === null) || (value === null))
				{
					continue;
				}
				
				if (args != "")
				{
					// attach 'and' operator
					args += "&";
				}
				args += key + "=" + escape(value);				
			}
			
			if (args != "")
			{
				url += "?" + args;
			}
			/*
			if (executeNativeCallIsActive || (mraid.getState() == states.Loading))
			{
				executeNativeCallQueue.push(url);
			} 
			else
			{
				executeNativeCallIsActive = true;
				window.location = url;
			}
			*/
			var iframe = document.createElement("IFRAME");
			iframe.setAttribute("src", url);
			document.documentElement.appendChild(iframe);
			iframe.parentNode.removeChild(iframe);
			iframe = null;
			
			return true;
		};
 		
		///////////////////////////////////////////////////////////////////////////////////////////////////////
		// mraid section
		
 		var mraid = this.mraid = {};

		var expandProperties =
 		{
 			width: -1,
 			height: -1,
			useCustomClose: false,
			isModal: true,
		};

		var placementType = placementTypes.Inline;
		var state = states.Loading;
		var viewable = false;
		var listeners = {};
		var geoLocation =
		{
			coords:
			{
				latitude: 0.0,
				longitude: 0.0,
			},
			accuracy: 0.0
		 };
 
 		if (this.navigator.geolocation)
 		{
 			this.navigator.geolocation.getCurrentPosition = function(success, error, options)
 			{
				executeNativeCall(nativeCommands.UpdateGeoLocation);
				success(geoLocation);
			}
		}
		  	
		mraid.getVersion = function ()
		{
			return "1.0";
		};
			
		mraid.getState = function ()
		{
			return state;
		};
			
		mraid.isViewable = function () 
		{
			return viewable;
		};
			
		mraid.close = function () 
		{
			if (state != states.Default && state != states.Expanded)
			{
				return;
			}

			return executeNativeCall(nativeCommands.Close);
		};
			
		mraid.open = function (url) 
		{
           	return executeNativeCall(nativeCommands.Open, "url", url);
        };

		mraid.expand = function () 
		{
			if (state != states.Default)
			{
				return;
			}
 
			var url = (1 <= arguments.length) ? arguments[0] : null;
 			
			if (url === null)
			{
				return executeNativeCall(nativeCommands.Expand);
			}
			else
			{
				return executeNativeCall(nativeCommands.Expand, "url", url);
			}
		};
			
		mraid.getPlacementType = function ()
		{
			return placementType;
		};

		mraid.getExpandProperties = function ()
		{
			return expandProperties;
		};
			
		mraid.setExpandProperties = function (properties)
		{
 			{
 				if (expandPropertiesCheckers.width(properties.width))
				{
					expandProperties.width = properties.width;
				}
				if (expandPropertiesCheckers.height(properties.height))
				{
					expandProperties.height = properties.height;
				}
				if (expandPropertiesCheckers.useCustomClose(properties.useCustomClose))
				{
					expandProperties.useCustomClose = properties.useCustomClose;
				}
 
				return executeNativeCall(nativeCommands.SetExpandProperties,
						  "width", expandProperties.width,
						  "height", expandProperties.height,
						  "useCustomClose", expandProperties.useCustomClose);
			}
			return false;				
		};
			
		mraid.useCustomClose = function (useCustomClose)
		{
			if (expandPropertiesCheckers.useCustomClose(useCustomClose))
			{
				expandProperties.useCustomClose = useCustomClose;
			}
		};
			
		mraid.addEventListener = function (event, listener) 
		{
			if (ES_CHECK_ENUMERATION(event, events, "mraid.addEventListener"))
			{
				return (listeners[event] || (listeners[event] = [])).push(listener);
			}
			else
			{
				return ES_LOG_ERROR("Can't add event listener. Invalid event name \"" + event + "\"", "mraid.addEventListener");
			}
		};
    	    
		mraid.removeEventListener = function () 
		{
			var event = arguments[0];
            var listener = (arguments.length > 1) ? Array.prototype.slice.call(arguments, 1) : [];
			var eventListeners = listeners[event];
            if (eventListeners && listener.length > 0) 
            {
				for (var i = 0, len = listener.length; i < len; i++)
				{
					var idx = eventListeners.indexOf(listener[i]);
					if (idx !== -1) 
					{
						eventListeners.splice(idx, 1);
					}					
				}
			}
			else
			{
				return eventListeners = [];
			}
		};
        
		mraid.fireEvent = function (event) 
		{
			var ref = listeners[event];
			if (ref) 
			{
				for (var i = 0, len = ref.length; i < len; i++)
				{
                   	var listener = ref[i];
					if (event === events.Ready)
						listener();
					if (event === events.StateChange)
						listener(state);
					if (event === events.ViewableChange) 
					{
                       	listener(viewable);
					} 
					else 
					{
                       	return false;
                   	}                   	
               	}
			}
           	return true;
	    };
	        
		mraid.fireLogEvent = function (eventType, message, action)
        {
			var ref = listeners[eventType];
			var results = [];
			if (ref)
			{
				for (var i = 0, len = ref.length; i < len; i++) 
				{
					var listener = ref[i];
					results.push(listener(message, action));
				}
			}
			return results;
		};

		mraid.fireErrorEvent = function (message, action)
        {
			return this.fireLogEvent(events.Error, message, action);
		};

		mraid.fireInfoEvent = function (message, action)
        {
			return this.fireLogEvent(events.Info, message, action);
		};
		
		mraid.logEntry = function (message)
        {
			ES_LOG_INFO(message, "mraid.logEntry");
		};
 
			
		//////////////////////////////////////////////////////////////////////////////////////////////////////
		// Objective-C callbacks
 
		var mraidback = this.mraidback = {};
		
		mraidback.updateExpandSize = function (width, height)
		{
			expandProperties.width = width;
			expandProperties.height = height;
			
			ES_LOG_INFO("updateExpandSize is called", "mraidback.updateExpandSize");
		};

 		mraidback.updateGeoLocation = function (latitude, longitude, accuracy)
		{
			geoLocation.coords.latitude = latitude;
			geoLocation.coords.longitude = longitude;
			geoLocation.accuracy = accuracy;
 
			ES_LOG_INFO("updateGeoLocation is called", "updateGeoLocation");
		};

		mraidback.setReady = function ()
		{
			ES_LOG_INFO("setReady is called", "mraidback.setReady");
 			return mraid.fireEvent(events.Ready);
		};
        
		mraidback.setState = function (newState)
		{
			ES_LOG_INFO("setState is called with state \"" + newState + "\"", "mraidback.setState");
			if (ES_CHECK_ENUMERATION(newState, states, "mraidback.setState"))
			{
				state = newState;
				return mraid.fireEvent(events.StateChange);
			}        	
			return false;
		};
        
		mraidback.setViewable = function (isViewable) 
		{
			ES_LOG_INFO("setViewable is called with value \"" + (isViewable ? "true" : "false") + "\"", "mraidback.setViewable");
			viewable = isViewable;
			return mraid.fireEvent(events.ViewableChange);
		};
        
		mraidback.setPlacementType = function (newPlacementType) 
		{
			ES_LOG_INFO("setPlacementType is called with placement type \"" + newPlacementType + "\"", "mraidback.setPlacementType");
			
			if (ES_CHECK_ENUMERATION(newPlacementType, placementTypes, "mraidback.setPlacementType"))
			{
				placementType = newPlacementType;
				return true;
			}
				
			return false;
	    };
	}
).call(window);
