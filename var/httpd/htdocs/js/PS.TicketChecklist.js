// --
// PS.TicketChecklist.js - provides the special module functions for the time tracking add on
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
PS.TicketChecklist = (function (TargetNS) {

    var BaseURL          = window.location.href.replace( window.location.search, "" );

    function NewItem () {
        var URL       = Core.Config.Get('Baselink') || BaseURL;

        $.ajax({
            type: 'POST',
            url: URL,
            dataType: 'json',
            data : {
                Action: 'AgentTicketChecklist',
                Subaction: 'NewItem',
                Position: Positions,
            },
            success: function(response) {
                if ( response.Error ) {
                    return;
                }

                var StatusSelect = $('<select name="ItemStatus_' + response.Position + '">');
                $.each( response.Status["ItemStatus_" + response.Position], function( Index, Value ) {
                    var Status = new Option( Value[1], Value[0], Value[2], Value[3] );
                    Status.innerHTML = Value[1];
                    StatusSelect.append( Status );
                });

                var TitleInput = $( '<input type="text" id="ItemTitle_' + response.Position + '" name="ItemTitle_' + response.Position + '">' );
                var DeleteBtn  = $( '<button name="DelBtn" id="DelBtn_' + response.Position + '" class="DelBtn CallForAction" value="-"><span>-</span></button>' );
                var ListItem = $('<li id="Item_' + response.Position + '">').append(
                    TitleInput
                ).append(
                    StatusSelect
                ).append(
                    DeleteBtn
                );

                DeleteBtn.bind('click', function(){ $(this).parent().remove() } );

                $('#ChecklistItems').append(
                    ListItem
                );

                Positions = response.Position;
            }
        });
    };

    function DeleteItem ( ItemID ) {
        var URL          = Core.Config.Get('Baselink') || BaseURL;
        var ListTicketID = $('#TicketID').val();

        $.ajax({
            type: 'POST',
            url: URL,
            dataType: 'json',
            data : {
                Action: 'AgentTicketChecklist',
                Subaction: 'Delete',
                TicketID: ListTicketID,
                ID: ItemID
            }
        });
    }

    $('#AddBtn').bind( 'click', function() {
        NewItem();
        return false;
    });

    $('button[name="DelBtn"]').bind( 'click', function() {
        var Pos       = $(this).attr('id').match( /\d+/ );
        var ID        = $(this).siblings( 'input[id="ItemID_' + Pos[0] + '"]' );

        $(this).parent().remove();

        if ( ID ) {
            DeleteItem( ID.val() );
        }

        return false;
    });

    return TargetNS;
}(PS.TicketChecklist || {}));
