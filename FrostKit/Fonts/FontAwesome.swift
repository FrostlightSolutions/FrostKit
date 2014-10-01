//
//  FontAwesome.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

//
//  How to update the FontAwesome unicode constants
//  -----------------------------------------------
//
//  1.  Copy the values from https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/less/variables.less
//  2.  Paste them in the 'variables.txt' file
//  3.  When in the 'variables.txt' file, press alt + cmd + 0 and add it to the FrostKit target
//  4.  Uncomment the testBuildFontAwesomeConstants() in FontTest and run the test
//  5.  Copy the constants printed in the debug console (they're wrapped in ----------)
//  6.  Paste the constants at the bottom of this file, replacing the ones alredy present
//  7.  Comment out testBuildFontAwesomeConstants() again
//  8.  Remove 'variables.txt' from the FrostKit target
//  9.  Update the .ttf font from https://github.com/FortAwesome/Font-Awesome/blob/master/fonts/fontawesome-webfont.ttf
//

import UIKit

public class FontAwesome: NSObject {
    
    public class func buildFontAwesomeConstants() -> Bool {
        
        let bundle = NSBundle(forClass: FontAwesome.self)
        if let url = bundle.URLForResource("variables", withExtension: "less") {
            
            if let path = url.path {
                
                if let contents = String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil) {
                    
                    var parts = contents.componentsSeparatedByString("\n\n")
                    let constantsString = parts[2]
                    
                    let items = constantsString.componentsSeparatedByString("\n")
                    
                    println("\n------------------------------\n")
                    
                    for item in items {
                        
                        var string = item.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        if string.isEmpty == false {
                            
                            string = string.stringByReplacingOccurrencesOfString("@", withString: "")
                            string = string.stringByReplacingOccurrencesOfString("-var", withString: "")
                            string = string.stringByReplacingOccurrencesOfString("-", withString: "_")
                            string = string.stringByReplacingOccurrencesOfString("\"", withString: "")
                            string = string.stringByReplacingOccurrencesOfString("\\", withString: "")
                            string = string.stringByReplacingOccurrencesOfString(";", withString: "")
                            
                            let array = string.componentsSeparatedByString(":")
                            let key = array[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                            let value = array[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                            
                            println("let \(key) = \"\\u{\(value)}\"")
                        }
                    }
                    
                    println("\n------------------------------\n")
                    
                    return true
                }
            }
        }
        
        return false
    }
    
}

let fa_adjust = "\u{f042}"
let fa_adn = "\u{f170}"
let fa_align_center = "\u{f037}"
let fa_align_justify = "\u{f039}"
let fa_align_left = "\u{f036}"
let fa_align_right = "\u{f038}"
let fa_ambulance = "\u{f0f9}"
let fa_anchor = "\u{f13d}"
let fa_android = "\u{f17b}"
let fa_angellist = "\u{f209}"
let fa_angle_double_down = "\u{f103}"
let fa_angle_double_left = "\u{f100}"
let fa_angle_double_right = "\u{f101}"
let fa_angle_double_up = "\u{f102}"
let fa_angle_down = "\u{f107}"
let fa_angle_left = "\u{f104}"
let fa_angle_right = "\u{f105}"
let fa_angle_up = "\u{f106}"
let fa_apple = "\u{f179}"
let fa_archive = "\u{f187}"
let fa_area_chart = "\u{f1fe}"
let fa_arrow_circle_down = "\u{f0ab}"
let fa_arrow_circle_left = "\u{f0a8}"
let fa_arrow_circle_o_down = "\u{f01a}"
let fa_arrow_circle_o_left = "\u{f190}"
let fa_arrow_circle_o_right = "\u{f18e}"
let fa_arrow_circle_o_up = "\u{f01b}"
let fa_arrow_circle_right = "\u{f0a9}"
let fa_arrow_circle_up = "\u{f0aa}"
let fa_arrow_down = "\u{f063}"
let fa_arrow_left = "\u{f060}"
let fa_arrow_right = "\u{f061}"
let fa_arrow_up = "\u{f062}"
let fa_arrows = "\u{f047}"
let fa_arrows_alt = "\u{f0b2}"
let fa_arrows_h = "\u{f07e}"
let fa_arrows_v = "\u{f07d}"
let fa_asterisk = "\u{f069}"
let fa_at = "\u{f1fa}"
let fa_automobile = "\u{f1b9}"
let fa_backward = "\u{f04a}"
let fa_ban = "\u{f05e}"
let fa_bank = "\u{f19c}"
let fa_bar_chart = "\u{f080}"
let fa_bar_chart_o = "\u{f080}"
let fa_barcode = "\u{f02a}"
let fa_bars = "\u{f0c9}"
let fa_beer = "\u{f0fc}"
let fa_behance = "\u{f1b4}"
let fa_behance_square = "\u{f1b5}"
let fa_bell = "\u{f0f3}"
let fa_bell_o = "\u{f0a2}"
let fa_bell_slash = "\u{f1f6}"
let fa_bell_slash_o = "\u{f1f7}"
let fa_bicycle = "\u{f206}"
let fa_binoculars = "\u{f1e5}"
let fa_birthday_cake = "\u{f1fd}"
let fa_bitbucket = "\u{f171}"
let fa_bitbucket_square = "\u{f172}"
let fa_bitcoin = "\u{f15a}"
let fa_bold = "\u{f032}"
let fa_bolt = "\u{f0e7}"
let fa_bomb = "\u{f1e2}"
let fa_book = "\u{f02d}"
let fa_bookmark = "\u{f02e}"
let fa_bookmark_o = "\u{f097}"
let fa_briefcase = "\u{f0b1}"
let fa_btc = "\u{f15a}"
let fa_bug = "\u{f188}"
let fa_building = "\u{f1ad}"
let fa_building_o = "\u{f0f7}"
let fa_bullhorn = "\u{f0a1}"
let fa_bullseye = "\u{f140}"
let fa_bus = "\u{f207}"
let fa_cab = "\u{f1ba}"
let fa_calculator = "\u{f1ec}"
let fa_calendar = "\u{f073}"
let fa_calendar_o = "\u{f133}"
let fa_camera = "\u{f030}"
let fa_camera_retro = "\u{f083}"
let fa_car = "\u{f1b9}"
let fa_caret_down = "\u{f0d7}"
let fa_caret_left = "\u{f0d9}"
let fa_caret_right = "\u{f0da}"
let fa_caret_square_o_down = "\u{f150}"
let fa_caret_square_o_left = "\u{f191}"
let fa_caret_square_o_right = "\u{f152}"
let fa_caret_square_o_up = "\u{f151}"
let fa_caret_up = "\u{f0d8}"
let fa_cc = "\u{f20a}"
let fa_cc_amex = "\u{f1f3}"
let fa_cc_discover = "\u{f1f2}"
let fa_cc_mastercard = "\u{f1f1}"
let fa_cc_paypal = "\u{f1f4}"
let fa_cc_stripe = "\u{f1f5}"
let fa_cc_visa = "\u{f1f0}"
let fa_certificate = "\u{f0a3}"
let fa_chain = "\u{f0c1}"
let fa_chain_broken = "\u{f127}"
let fa_check = "\u{f00c}"
let fa_check_circle = "\u{f058}"
let fa_check_circle_o = "\u{f05d}"
let fa_check_square = "\u{f14a}"
let fa_check_square_o = "\u{f046}"
let fa_chevron_circle_down = "\u{f13a}"
let fa_chevron_circle_left = "\u{f137}"
let fa_chevron_circle_right = "\u{f138}"
let fa_chevron_circle_up = "\u{f139}"
let fa_chevron_down = "\u{f078}"
let fa_chevron_left = "\u{f053}"
let fa_chevron_right = "\u{f054}"
let fa_chevron_up = "\u{f077}"
let fa_child = "\u{f1ae}"
let fa_circle = "\u{f111}"
let fa_circle_o = "\u{f10c}"
let fa_circle_o_notch = "\u{f1ce}"
let fa_circle_thin = "\u{f1db}"
let fa_clipboard = "\u{f0ea}"
let fa_clock_o = "\u{f017}"
let fa_close = "\u{f00d}"
let fa_cloud = "\u{f0c2}"
let fa_cloud_download = "\u{f0ed}"
let fa_cloud_upload = "\u{f0ee}"
let fa_cny = "\u{f157}"
let fa_code = "\u{f121}"
let fa_code_fork = "\u{f126}"
let fa_codepen = "\u{f1cb}"
let fa_coffee = "\u{f0f4}"
let fa_cog = "\u{f013}"
let fa_cogs = "\u{f085}"
let fa_columns = "\u{f0db}"
let fa_comment = "\u{f075}"
let fa_comment_o = "\u{f0e5}"
let fa_comments = "\u{f086}"
let fa_comments_o = "\u{f0e6}"
let fa_compass = "\u{f14e}"
let fa_compress = "\u{f066}"
let fa_copy = "\u{f0c5}"
let fa_copyright = "\u{f1f9}"
let fa_credit_card = "\u{f09d}"
let fa_crop = "\u{f125}"
let fa_crosshairs = "\u{f05b}"
let fa_css3 = "\u{f13c}"
let fa_cube = "\u{f1b2}"
let fa_cubes = "\u{f1b3}"
let fa_cut = "\u{f0c4}"
let fa_cutlery = "\u{f0f5}"
let fa_dashboard = "\u{f0e4}"
let fa_database = "\u{f1c0}"
let fa_dedent = "\u{f03b}"
let fa_delicious = "\u{f1a5}"
let fa_desktop = "\u{f108}"
let fa_deviantart = "\u{f1bd}"
let fa_digg = "\u{f1a6}"
let fa_dollar = "\u{f155}"
let fa_dot_circle_o = "\u{f192}"
let fa_download = "\u{f019}"
let fa_dribbble = "\u{f17d}"
let fa_dropbox = "\u{f16b}"
let fa_drupal = "\u{f1a9}"
let fa_edit = "\u{f044}"
let fa_eject = "\u{f052}"
let fa_ellipsis_h = "\u{f141}"
let fa_ellipsis_v = "\u{f142}"
let fa_empire = "\u{f1d1}"
let fa_envelope = "\u{f0e0}"
let fa_envelope_o = "\u{f003}"
let fa_envelope_square = "\u{f199}"
let fa_eraser = "\u{f12d}"
let fa_eur = "\u{f153}"
let fa_euro = "\u{f153}"
let fa_exchange = "\u{f0ec}"
let fa_exclamation = "\u{f12a}"
let fa_exclamation_circle = "\u{f06a}"
let fa_exclamation_triangle = "\u{f071}"
let fa_expand = "\u{f065}"
let fa_external_link = "\u{f08e}"
let fa_external_link_square = "\u{f14c}"
let fa_eye = "\u{f06e}"
let fa_eye_slash = "\u{f070}"
let fa_eyedropper = "\u{f1fb}"
let fa_facebook = "\u{f09a}"
let fa_facebook_square = "\u{f082}"
let fa_fast_backward = "\u{f049}"
let fa_fast_forward = "\u{f050}"
let fa_fax = "\u{f1ac}"
let fa_female = "\u{f182}"
let fa_fighter_jet = "\u{f0fb}"
let fa_file = "\u{f15b}"
let fa_file_archive_o = "\u{f1c6}"
let fa_file_audio_o = "\u{f1c7}"
let fa_file_code_o = "\u{f1c9}"
let fa_file_excel_o = "\u{f1c3}"
let fa_file_image_o = "\u{f1c5}"
let fa_file_movie_o = "\u{f1c8}"
let fa_file_o = "\u{f016}"
let fa_file_pdf_o = "\u{f1c1}"
let fa_file_photo_o = "\u{f1c5}"
let fa_file_picture_o = "\u{f1c5}"
let fa_file_powerpoint_o = "\u{f1c4}"
let fa_file_sound_o = "\u{f1c7}"
let fa_file_text = "\u{f15c}"
let fa_file_text_o = "\u{f0f6}"
let fa_file_video_o = "\u{f1c8}"
let fa_file_word_o = "\u{f1c2}"
let fa_file_zip_o = "\u{f1c6}"
let fa_files_o = "\u{f0c5}"
let fa_film = "\u{f008}"
let fa_filter = "\u{f0b0}"
let fa_fire = "\u{f06d}"
let fa_fire_extinguisher = "\u{f134}"
let fa_flag = "\u{f024}"
let fa_flag_checkered = "\u{f11e}"
let fa_flag_o = "\u{f11d}"
let fa_flash = "\u{f0e7}"
let fa_flask = "\u{f0c3}"
let fa_flickr = "\u{f16e}"
let fa_floppy_o = "\u{f0c7}"
let fa_folder = "\u{f07b}"
let fa_folder_o = "\u{f114}"
let fa_folder_open = "\u{f07c}"
let fa_folder_open_o = "\u{f115}"
let fa_font = "\u{f031}"
let fa_forward = "\u{f04e}"
let fa_foursquare = "\u{f180}"
let fa_frown_o = "\u{f119}"
let fa_futbol_o = "\u{f1e3}"
let fa_gamepad = "\u{f11b}"
let fa_gavel = "\u{f0e3}"
let fa_gbp = "\u{f154}"
let fa_ge = "\u{f1d1}"
let fa_gear = "\u{f013}"
let fa_gears = "\u{f085}"
let fa_gift = "\u{f06b}"
let fa_git = "\u{f1d3}"
let fa_git_square = "\u{f1d2}"
let fa_github = "\u{f09b}"
let fa_github_alt = "\u{f113}"
let fa_github_square = "\u{f092}"
let fa_gittip = "\u{f184}"
let fa_glass = "\u{f000}"
let fa_globe = "\u{f0ac}"
let fa_google = "\u{f1a0}"
let fa_google_plus = "\u{f0d5}"
let fa_google_plus_square = "\u{f0d4}"
let fa_google_wallet = "\u{f1ee}"
let fa_graduation_cap = "\u{f19d}"
let fa_group = "\u{f0c0}"
let fa_h_square = "\u{f0fd}"
let fa_hacker_news = "\u{f1d4}"
let fa_hand_o_down = "\u{f0a7}"
let fa_hand_o_left = "\u{f0a5}"
let fa_hand_o_right = "\u{f0a4}"
let fa_hand_o_up = "\u{f0a6}"
let fa_hdd_o = "\u{f0a0}"
let fa_header = "\u{f1dc}"
let fa_headphones = "\u{f025}"
let fa_heart = "\u{f004}"
let fa_heart_o = "\u{f08a}"
let fa_history = "\u{f1da}"
let fa_home = "\u{f015}"
let fa_hospital_o = "\u{f0f8}"
let fa_html5 = "\u{f13b}"
let fa_ils = "\u{f20b}"
let fa_image = "\u{f03e}"
let fa_inbox = "\u{f01c}"
let fa_indent = "\u{f03c}"
let fa_info = "\u{f129}"
let fa_info_circle = "\u{f05a}"
let fa_inr = "\u{f156}"
let fa_instagram = "\u{f16d}"
let fa_institution = "\u{f19c}"
let fa_ioxhost = "\u{f208}"
let fa_italic = "\u{f033}"
let fa_joomla = "\u{f1aa}"
let fa_jpy = "\u{f157}"
let fa_jsfiddle = "\u{f1cc}"
let fa_key = "\u{f084}"
let fa_keyboard_o = "\u{f11c}"
let fa_krw = "\u{f159}"
let fa_language = "\u{f1ab}"
let fa_laptop = "\u{f109}"
let fa_lastfm = "\u{f202}"
let fa_lastfm_square = "\u{f203}"
let fa_leaf = "\u{f06c}"
let fa_legal = "\u{f0e3}"
let fa_lemon_o = "\u{f094}"
let fa_level_down = "\u{f149}"
let fa_level_up = "\u{f148}"
let fa_life_bouy = "\u{f1cd}"
let fa_life_buoy = "\u{f1cd}"
let fa_life_ring = "\u{f1cd}"
let fa_life_saver = "\u{f1cd}"
let fa_lightbulb_o = "\u{f0eb}"
let fa_line_chart = "\u{f201}"
let fa_link = "\u{f0c1}"
let fa_linkedin = "\u{f0e1}"
let fa_linkedin_square = "\u{f08c}"
let fa_linux = "\u{f17c}"
let fa_list = "\u{f03a}"
let fa_list_alt = "\u{f022}"
let fa_list_ol = "\u{f0cb}"
let fa_list_ul = "\u{f0ca}"
let fa_location_arrow = "\u{f124}"
let fa_lock = "\u{f023}"
let fa_long_arrow_down = "\u{f175}"
let fa_long_arrow_left = "\u{f177}"
let fa_long_arrow_right = "\u{f178}"
let fa_long_arrow_up = "\u{f176}"
let fa_magic = "\u{f0d0}"
let fa_magnet = "\u{f076}"
let fa_mail_forward = "\u{f064}"
let fa_mail_reply = "\u{f112}"
let fa_mail_reply_all = "\u{f122}"
let fa_male = "\u{f183}"
let fa_map_marker = "\u{f041}"
let fa_maxcdn = "\u{f136}"
let fa_meanpath = "\u{f20c}"
let fa_medkit = "\u{f0fa}"
let fa_meh_o = "\u{f11a}"
let fa_microphone = "\u{f130}"
let fa_microphone_slash = "\u{f131}"
let fa_minus = "\u{f068}"
let fa_minus_circle = "\u{f056}"
let fa_minus_square = "\u{f146}"
let fa_minus_square_o = "\u{f147}"
let fa_mobile = "\u{f10b}"
let fa_mobile_phone = "\u{f10b}"
let fa_money = "\u{f0d6}"
let fa_moon_o = "\u{f186}"
let fa_mortar_board = "\u{f19d}"
let fa_music = "\u{f001}"
let fa_navicon = "\u{f0c9}"
let fa_newspaper_o = "\u{f1ea}"
let fa_openid = "\u{f19b}"
let fa_outdent = "\u{f03b}"
let fa_pagelines = "\u{f18c}"
let fa_paint_brush = "\u{f1fc}"
let fa_paper_plane = "\u{f1d8}"
let fa_paper_plane_o = "\u{f1d9}"
let fa_paperclip = "\u{f0c6}"
let fa_paragraph = "\u{f1dd}"
let fa_paste = "\u{f0ea}"
let fa_pause = "\u{f04c}"
let fa_paw = "\u{f1b0}"
let fa_paypal = "\u{f1ed}"
let fa_pencil = "\u{f040}"
let fa_pencil_square = "\u{f14b}"
let fa_pencil_square_o = "\u{f044}"
let fa_phone = "\u{f095}"
let fa_phone_square = "\u{f098}"
let fa_photo = "\u{f03e}"
let fa_picture_o = "\u{f03e}"
let fa_pie_chart = "\u{f200}"
let fa_pied_piper = "\u{f1a7}"
let fa_pied_piper_alt = "\u{f1a8}"
let fa_pinterest = "\u{f0d2}"
let fa_pinterest_square = "\u{f0d3}"
let fa_plane = "\u{f072}"
let fa_play = "\u{f04b}"
let fa_play_circle = "\u{f144}"
let fa_play_circle_o = "\u{f01d}"
let fa_plug = "\u{f1e6}"
let fa_plus = "\u{f067}"
let fa_plus_circle = "\u{f055}"
let fa_plus_square = "\u{f0fe}"
let fa_plus_square_o = "\u{f196}"
let fa_power_off = "\u{f011}"
let fa_print = "\u{f02f}"
let fa_puzzle_piece = "\u{f12e}"
let fa_qq = "\u{f1d6}"
let fa_qrcode = "\u{f029}"
let fa_question = "\u{f128}"
let fa_question_circle = "\u{f059}"
let fa_quote_left = "\u{f10d}"
let fa_quote_right = "\u{f10e}"
let fa_ra = "\u{f1d0}"
let fa_random = "\u{f074}"
let fa_rebel = "\u{f1d0}"
let fa_recycle = "\u{f1b8}"
let fa_reddit = "\u{f1a1}"
let fa_reddit_square = "\u{f1a2}"
let fa_refresh = "\u{f021}"
let fa_remove = "\u{f00d}"
let fa_renren = "\u{f18b}"
let fa_reorder = "\u{f0c9}"
let fa_repeat = "\u{f01e}"
let fa_reply = "\u{f112}"
let fa_reply_all = "\u{f122}"
let fa_retweet = "\u{f079}"
let fa_rmb = "\u{f157}"
let fa_road = "\u{f018}"
let fa_rocket = "\u{f135}"
let fa_rotate_left = "\u{f0e2}"
let fa_rotate_right = "\u{f01e}"
let fa_rouble = "\u{f158}"
let fa_rss = "\u{f09e}"
let fa_rss_square = "\u{f143}"
let fa_rub = "\u{f158}"
let fa_ruble = "\u{f158}"
let fa_rupee = "\u{f156}"
let fa_save = "\u{f0c7}"
let fa_scissors = "\u{f0c4}"
let fa_search = "\u{f002}"
let fa_search_minus = "\u{f010}"
let fa_search_plus = "\u{f00e}"
let fa_send = "\u{f1d8}"
let fa_send_o = "\u{f1d9}"
let fa_share = "\u{f064}"
let fa_share_alt = "\u{f1e0}"
let fa_share_alt_square = "\u{f1e1}"
let fa_share_square = "\u{f14d}"
let fa_share_square_o = "\u{f045}"
let fa_shekel = "\u{f20b}"
let fa_sheqel = "\u{f20b}"
let fa_shield = "\u{f132}"
let fa_shopping_cart = "\u{f07a}"
let fa_sign_in = "\u{f090}"
let fa_sign_out = "\u{f08b}"
let fa_signal = "\u{f012}"
let fa_sitemap = "\u{f0e8}"
let fa_skype = "\u{f17e}"
let fa_slack = "\u{f198}"
let fa_sliders = "\u{f1de}"
let fa_slideshare = "\u{f1e7}"
let fa_smile_o = "\u{f118}"
let fa_soccer_ball_o = "\u{f1e3}"
let fa_sort = "\u{f0dc}"
let fa_sort_alpha_asc = "\u{f15d}"
let fa_sort_alpha_desc = "\u{f15e}"
let fa_sort_amount_asc = "\u{f160}"
let fa_sort_amount_desc = "\u{f161}"
let fa_sort_asc = "\u{f0de}"
let fa_sort_desc = "\u{f0dd}"
let fa_sort_down = "\u{f0dd}"
let fa_sort_numeric_asc = "\u{f162}"
let fa_sort_numeric_desc = "\u{f163}"
let fa_sort_up = "\u{f0de}"
let fa_soundcloud = "\u{f1be}"
let fa_space_shuttle = "\u{f197}"
let fa_spinner = "\u{f110}"
let fa_spoon = "\u{f1b1}"
let fa_spotify = "\u{f1bc}"
let fa_square = "\u{f0c8}"
let fa_square_o = "\u{f096}"
let fa_stack_exchange = "\u{f18d}"
let fa_stack_overflow = "\u{f16c}"
let fa_star = "\u{f005}"
let fa_star_half = "\u{f089}"
let fa_star_half_empty = "\u{f123}"
let fa_star_half_full = "\u{f123}"
let fa_star_half_o = "\u{f123}"
let fa_star_o = "\u{f006}"
let fa_steam = "\u{f1b6}"
let fa_steam_square = "\u{f1b7}"
let fa_step_backward = "\u{f048}"
let fa_step_forward = "\u{f051}"
let fa_stethoscope = "\u{f0f1}"
let fa_stop = "\u{f04d}"
let fa_strikethrough = "\u{f0cc}"
let fa_stumbleupon = "\u{f1a4}"
let fa_stumbleupon_circle = "\u{f1a3}"
let fa_subscript = "\u{f12c}"
let fa_suitcase = "\u{f0f2}"
let fa_sun_o = "\u{f185}"
let fa_superscript = "\u{f12b}"
let fa_support = "\u{f1cd}"
let fa_table = "\u{f0ce}"
let fa_tablet = "\u{f10a}"
let fa_tachometer = "\u{f0e4}"
let fa_tag = "\u{f02b}"
let fa_tags = "\u{f02c}"
let fa_tasks = "\u{f0ae}"
let fa_taxi = "\u{f1ba}"
let fa_tencent_weibo = "\u{f1d5}"
let fa_terminal = "\u{f120}"
let fa_text_height = "\u{f034}"
let fa_text_width = "\u{f035}"
let fa_th = "\u{f00a}"
let fa_th_large = "\u{f009}"
let fa_th_list = "\u{f00b}"
let fa_thumb_tack = "\u{f08d}"
let fa_thumbs_down = "\u{f165}"
let fa_thumbs_o_down = "\u{f088}"
let fa_thumbs_o_up = "\u{f087}"
let fa_thumbs_up = "\u{f164}"
let fa_ticket = "\u{f145}"
let fa_times = "\u{f00d}"
let fa_times_circle = "\u{f057}"
let fa_times_circle_o = "\u{f05c}"
let fa_tint = "\u{f043}"
let fa_toggle_down = "\u{f150}"
let fa_toggle_left = "\u{f191}"
let fa_toggle_off = "\u{f204}"
let fa_toggle_on = "\u{f205}"
let fa_toggle_right = "\u{f152}"
let fa_toggle_up = "\u{f151}"
let fa_trash = "\u{f1f8}"
let fa_trash_o = "\u{f014}"
let fa_tree = "\u{f1bb}"
let fa_trello = "\u{f181}"
let fa_trophy = "\u{f091}"
let fa_truck = "\u{f0d1}"
let fa_try = "\u{f195}"
let fa_tty = "\u{f1e4}"
let fa_tumblr = "\u{f173}"
let fa_tumblr_square = "\u{f174}"
let fa_turkish_lira = "\u{f195}"
let fa_twitch = "\u{f1e8}"
let fa_twitter = "\u{f099}"
let fa_twitter_square = "\u{f081}"
let fa_umbrella = "\u{f0e9}"
let fa_underline = "\u{f0cd}"
let fa_undo = "\u{f0e2}"
let fa_university = "\u{f19c}"
let fa_unlink = "\u{f127}"
let fa_unlock = "\u{f09c}"
let fa_unlock_alt = "\u{f13e}"
let fa_unsorted = "\u{f0dc}"
let fa_upload = "\u{f093}"
let fa_usd = "\u{f155}"
let fa_user = "\u{f007}"
let fa_user_md = "\u{f0f0}"
let fa_users = "\u{f0c0}"
let fa_video_camera = "\u{f03d}"
let fa_vimeo_square = "\u{f194}"
let fa_vine = "\u{f1ca}"
let fa_vk = "\u{f189}"
let fa_volume_down = "\u{f027}"
let fa_volume_off = "\u{f026}"
let fa_volume_up = "\u{f028}"
let fa_warning = "\u{f071}"
let fa_wechat = "\u{f1d7}"
let fa_weibo = "\u{f18a}"
let fa_weixin = "\u{f1d7}"
let fa_wheelchair = "\u{f193}"
let fa_wifi = "\u{f1eb}"
let fa_windows = "\u{f17a}"
let fa_won = "\u{f159}"
let fa_wordpress = "\u{f19a}"
let fa_wrench = "\u{f0ad}"
let fa_xing = "\u{f168}"
let fa_xing_square = "\u{f169}"
let fa_yahoo = "\u{f19e}"
let fa_yelp = "\u{f1e9}"
let fa_yen = "\u{f157}"
let fa_youtube = "\u{f167}"
let fa_youtube_play = "\u{f16a}"
let fa_youtube_square = "\u{f166}"
