// --
// PS.TicketChecklistWidget.js - provides the special module functions for the time tracking add on
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var PS = PS || {};

/**
 * @namespace
 * @exports TargetNS as PS.TicketChecklist
 * @description
 *      This namespace contains the special module functions for the time tracking add on
 */
PS.TicketChecklistWidget = (function (TargetNS) {

    var BaseURL          = window.location.href.replace( window.location.search, "" );

    function UpdateItem ( ItemID, ItemStatusID, ItemTicketID, Position ) {
        var URL       = Core.Config.Get('Baselink') || BaseURL;

        $.ajax({
            type: 'POST',
            url: URL,
            dataType: 'json',
            data : {
                Action: 'AgentTicketChecklist',
                Subaction: 'UpdateItemStatus',
                ID: ItemID,
                StatusID: ItemStatusID,
                TicketID: ItemTicketID,
                ItemPosition: Position
            },
            success: function(response) {
                if ( response.Error ) {
                    return;
                }

                $('#ItemFlag_' + response.Position).css( 'background-color', response.Color );
            }
        });
    };

    TargetNS.Init = function() {

        $('#PS-Checklist-Customer-View').bind('change', function() {
            var is_checked = 0;

            if ($(this).is(':checked') ) {
                is_checked = 1;
            }

            var URL = Core.Config.Get('Baselink') || BaseURL;
            $.ajax({
                type: 'POST',
                url: URL,
                dataType: 'json',
                data : {
                    Action: 'AgentTicketChecklistCustomerVisibility',
                    TicketID: Core.Config.Get("TicketID"),
                    CustomerVisibility: is_checked
                }
            });
        });

        Core.UI.InputFields.InitSelect( $('select[id^="ItemStatusWidget_"]') );

        $('select[name^="ItemStatusWidget"]').bind( 'change', function() {
            var Pos       = $(this).attr('id').match( /\d+/ );
            var ID        = $('#ItemID_' + Pos[0]);
            var TicketID  = $('#ChecklistTicketID').val();

            if ( ID ) {
                UpdateItem( ID.val(), $(this).val(), TicketID, Pos[0] );
            }

            return false;
        });
    };

    TargetNS.Init();

    TargetNS.GotoArticle = function( ArticleID ) {
        if ( $('.AllArticles').hasClass('Active') ) {
            window.location.hash = 'Article' + ArticleID;
        }

        window.location.hash = ArticleID;
        Core.Agent.TicketZoom.CheckURLHash();
    };

    return TargetNS;
}(PS.TicketChecklistWidget || {}));
