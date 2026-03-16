#!/usr/bin/env python3
"""Generate detailsMatter.xcodeproj/project.pbxproj with Firebase SPM dependencies"""
import os, uuid

BASE = os.path.dirname(os.path.abspath(__file__))
PROJ = os.path.join(BASE, "detailsMatter.xcodeproj")
WS   = os.path.join(PROJ, "project.xcworkspace")

def uid(): return uuid.uuid4().hex[:24].upper()

def write(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f: f.write(content)

# ── All Swift source files (path relative to detailsMatter/ source dir) ──────
SWIFT_FILES = [
    "detailsMatterApp.swift",
    "ContentView.swift",
    "SharedComponents.swift",
    "Models/DMUser.swift",
    "Models/Appointment.swift",
    "Models/TimeSlot.swift",
    "Models/DetailService.swift",
    "Models/VehicleInfo.swift",
    "Services/AuthService.swift",
    "Services/FirestoreService.swift",
    "Services/DemoData.swift",
    "ViewModels/AuthViewModel.swift",
    "ViewModels/ClientHomeViewModel.swift",
    "ViewModels/CalendarViewModel.swift",
    "ViewModels/BookingViewModel.swift",
    "ViewModels/AppointmentDetailViewModel.swift",
    "ViewModels/AdminDashboardViewModel.swift",
    "ViewModels/AdminSlotsViewModel.swift",
    "Views/Auth/LoginView.swift",
    "Views/Auth/SMSVerificationView.swift",
    "Views/Auth/AdminLoginView.swift",
    "Views/Client/ClientHomeView.swift",
    "Views/Client/CalendarView.swift",
    "Views/Client/TimeSlotPickerView.swift",
    "Views/Client/BookingFormView.swift",
    "Views/Client/AppointmentDetailView.swift",
    "Views/Admin/AdminDashboardView.swift",
    "Views/Admin/AdminSlotManagerView.swift",
    "Views/Admin/AdminAppointmentDetailView.swift",
]

# ── Generate UUIDs ────────────────────────────────────────────────────────────
IDs = {f: (uid(), uid()) for f in SWIFT_FILES}  # (fileRef, buildFile)

ASSETS_REF   = uid(); ASSETS_BUILD   = uid()
PLIST_REF    = uid(); PLIST_BUILD    = uid()
PREVIEW_REF  = uid()
PRODUCT_REF  = uid()

ROOT_GRP     = uid(); MAIN_GRP       = uid(); PRODUCTS_GRP = uid()
MODELS_GRP   = uid(); SERVICES_GRP   = uid()
VMODELS_GRP  = uid(); VIEWS_GRP      = uid()
VIEWS_AUTH_GRP   = uid(); VIEWS_CLIENT_GRP = uid(); VIEWS_ADMIN_GRP = uid()

TARGET_UUID  = uid(); PROJECT_UUID   = uid()
SOURCES_PH   = uid(); FRAMEWORKS_PH  = uid(); RESOURCES_PH = uid()
PROJ_CFGLIST = uid(); TGT_CFGLIST    = uid()
PROJ_DEBUG   = uid(); PROJ_RELEASE   = uid()
TGT_DEBUG    = uid(); TGT_RELEASE    = uid()

# Firebase SPM UUIDs
PKG_REF              = uid()
FIREBASE_AUTH_DEP    = uid(); FIREBASE_AUTH_BUILD    = uid()
FIREBASE_FS_DEP      = uid(); FIREBASE_FS_BUILD      = uid()

# ── Helper functions ──────────────────────────────────────────────────────────
def file_ref_line(path, fid):
    name = os.path.basename(path)
    return f'\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = "<group>"; }};'

def build_file_line(path, fid, bfid):
    name = os.path.basename(path)
    return f'\t\t{bfid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {name} */; }};'

def children_str(lst):
    return "\n".join(f"\t\t\t\t{fid} /* {name} */," for fid, name in lst)

# Group member lists
models_ids       = [(IDs[f][0], os.path.basename(f)) for f in SWIFT_FILES if f.startswith("Models/")]
services_ids     = [(IDs[f][0], os.path.basename(f)) for f in SWIFT_FILES if f.startswith("Services/")]
vmodels_ids      = [(IDs[f][0], os.path.basename(f)) for f in SWIFT_FILES if f.startswith("ViewModels/")]
views_auth_ids   = [(IDs[f][0], os.path.basename(f)) for f in SWIFT_FILES if f.startswith("Views/Auth/")]
views_client_ids = [(IDs[f][0], os.path.basename(f)) for f in SWIFT_FILES if f.startswith("Views/Client/")]
views_admin_ids  = [(IDs[f][0], os.path.basename(f)) for f in SWIFT_FILES if f.startswith("Views/Admin/")]
root_files       = [(IDs[f][0], os.path.basename(f)) for f in SWIFT_FILES if "/" not in f]

pbxproj = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{}};
\tobjectVersion = 77;
\tobjects = {{

/* Begin PBXBuildFile section */
{chr(10).join(build_file_line(f, IDs[f][0], IDs[f][1]) for f in SWIFT_FILES)}
\t\t{ASSETS_BUILD} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {ASSETS_REF} /* Assets.xcassets */; }};
\t\t{PLIST_BUILD} /* GoogleService-Info.plist in Resources */ = {{isa = PBXBuildFile; fileRef = {PLIST_REF} /* GoogleService-Info.plist */; }};
\t\t{FIREBASE_AUTH_BUILD} /* FirebaseAuth in Frameworks */ = {{isa = PBXBuildFile; productRef = {FIREBASE_AUTH_DEP} /* FirebaseAuth */; }};
\t\t{FIREBASE_FS_BUILD} /* FirebaseFirestore in Frameworks */ = {{isa = PBXBuildFile; productRef = {FIREBASE_FS_DEP} /* FirebaseFirestore */; }};
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{chr(10).join(file_ref_line(f, IDs[f][0]) for f in SWIFT_FILES)}
\t\t{ASSETS_REF} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};
\t\t{PLIST_REF} /* GoogleService-Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "GoogleService-Info.plist"; sourceTree = "<group>"; }};
\t\t{PREVIEW_REF} /* Preview Content */ = {{isa = PBXFileReference; lastKnownFileType = folder; path = "Preview Content"; sourceTree = "<group>"; }};
\t\t{PRODUCT_REF} /* detailsMatter.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = detailsMatter.app; sourceTree = BUILT_PRODUCTS_DIR; }};
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{FRAMEWORKS_PH} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{FIREBASE_AUTH_BUILD} /* FirebaseAuth in Frameworks */,
\t\t\t\t{FIREBASE_FS_BUILD} /* FirebaseFirestore in Frameworks */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{ROOT_GRP} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{MAIN_GRP} /* detailsMatter */,
\t\t\t\t{PRODUCTS_GRP} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{PRODUCTS_GRP} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{PRODUCT_REF} /* detailsMatter.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{MAIN_GRP} /* detailsMatter */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{children_str(root_files)}
\t\t\t\t{MODELS_GRP} /* Models */,
\t\t\t\t{SERVICES_GRP} /* Services */,
\t\t\t\t{VMODELS_GRP} /* ViewModels */,
\t\t\t\t{VIEWS_GRP} /* Views */,
\t\t\t\t{PLIST_REF} /* GoogleService-Info.plist */,
\t\t\t\t{ASSETS_REF} /* Assets.xcassets */,
\t\t\t\t{PREVIEW_REF} /* Preview Content */,
\t\t\t);
\t\t\tpath = detailsMatter;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{MODELS_GRP} /* Models */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{children_str(models_ids)}
\t\t\t);
\t\t\tpath = Models;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{SERVICES_GRP} /* Services */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{children_str(services_ids)}
\t\t\t);
\t\t\tpath = Services;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{VMODELS_GRP} /* ViewModels */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{children_str(vmodels_ids)}
\t\t\t);
\t\t\tpath = ViewModels;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{VIEWS_GRP} /* Views */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{VIEWS_AUTH_GRP} /* Auth */,
\t\t\t\t{VIEWS_CLIENT_GRP} /* Client */,
\t\t\t\t{VIEWS_ADMIN_GRP} /* Admin */,
\t\t\t);
\t\t\tpath = Views;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{VIEWS_AUTH_GRP} /* Auth */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{children_str(views_auth_ids)}
\t\t\t);
\t\t\tpath = Auth;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{VIEWS_CLIENT_GRP} /* Client */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{children_str(views_client_ids)}
\t\t\t);
\t\t\tpath = Client;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{VIEWS_ADMIN_GRP} /* Admin */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{children_str(views_admin_ids)}
\t\t\t);
\t\t\tpath = Admin;
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{TARGET_UUID} /* detailsMatter */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {TGT_CFGLIST} /* Build configuration list for PBXNativeTarget "detailsMatter" */;
\t\t\tbuildPhases = (
\t\t\t\t{SOURCES_PH} /* Sources */,
\t\t\t\t{FRAMEWORKS_PH} /* Frameworks */,
\t\t\t\t{RESOURCES_PH} /* Resources */,
\t\t\t);
\t\t\tbuildRules = ();
\t\t\tdependencies = ();
\t\t\tname = detailsMatter;
\t\t\tpackageProductDependencies = (
\t\t\t\t{FIREBASE_AUTH_DEP} /* FirebaseAuth */,
\t\t\t\t{FIREBASE_FS_DEP} /* FirebaseFirestore */,
\t\t\t);
\t\t\tproductName = detailsMatter;
\t\t\tproductReference = {PRODUCT_REF} /* detailsMatter.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{PROJECT_UUID} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1630;
\t\t\t\tLastUpgradeCheck = 1630;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{TARGET_UUID} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 16.3;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {PROJ_CFGLIST} /* Build configuration list for PBXProject "detailsMatter" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {ROOT_GRP};
\t\t\tpackageReferences = (
\t\t\t\t{PKG_REF} /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */,
\t\t\t);
\t\t\tproductRefGroup = {PRODUCTS_GRP} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{TARGET_UUID} /* detailsMatter */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{RESOURCES_PH} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{ASSETS_BUILD} /* Assets.xcassets in Resources */,
\t\t\t\t{PLIST_BUILD} /* GoogleService-Info.plist in Resources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{SOURCES_PH} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(f"\t\t\t\t{IDs[f][1]} /* {os.path.basename(f)} in Sources */," for f in SWIFT_FILES)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t{PROJ_DEBUG} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_CYCLE = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG DEMO_MODE";
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{PROJ_RELEASE} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{TGT_DEBUG} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSTCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSTCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_ASSET_PATHS = "\\"detailsMatter/Preview Content\\"";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tOTHER_LDFLAGS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"-ObjC",
\t\t\t\t);
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.detailsMatter.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{TGT_RELEASE} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSTCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSTCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_ASSET_PATHS = "\\"detailsMatter/Preview Content\\"";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tOTHER_LDFLAGS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"-ObjC",
\t\t\t\t);
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.detailsMatter.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{PROJ_CFGLIST} /* Build configuration list for PBXProject "detailsMatter" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{PROJ_DEBUG} /* Debug */,
\t\t\t\t{PROJ_RELEASE} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{TGT_CFGLIST} /* Build configuration list for PBXNativeTarget "detailsMatter" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{TGT_DEBUG} /* Debug */,
\t\t\t\t{TGT_RELEASE} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */

/* Begin XCRemoteSwiftPackageReference section */
\t\t{PKG_REF} /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */ = {{
\t\t\tisa = XCRemoteSwiftPackageReference;
\t\t\trepositoryURL = "https://github.com/firebase/firebase-ios-sdk";
\t\t\trequirement = {{
\t\t\t\tkind = upToNextMajorVersion;
\t\t\t\tminimumVersion = 11.0.0;
\t\t\t}};
\t\t}};
/* End XCRemoteSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
\t\t{FIREBASE_AUTH_DEP} /* FirebaseAuth */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {PKG_REF} /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */;
\t\t\tproductName = FirebaseAuth;
\t\t}};
\t\t{FIREBASE_FS_DEP} /* FirebaseFirestore */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {PKG_REF} /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */;
\t\t\tproductName = FirebaseFirestore;
\t\t}};
/* End XCSwiftPackageProductDependency section */

\t}};
\trootObject = {PROJECT_UUID} /* Project object */;
}}
"""

write(os.path.join(PROJ, "project.pbxproj"), pbxproj)

write(os.path.join(WS, "contents.xcworkspacedata"),
"""<?xml version="1.0" encoding="UTF-8"?>
<Workspace version = "1.0">
   <FileRef location = "self:">
   </FileRef>
</Workspace>
""")

write(os.path.join(WS, "xcshareddata", "WorkspaceSettings.xcsettings"),
"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
\t<key>PreviewsEnabled</key>
\t<false/>
</dict>
</plist>
""")

# ── Asset catalogs ────────────────────────────────────────────────────────────
SRC = os.path.join(BASE, "detailsMatter")

write(os.path.join(SRC, "Assets.xcassets", "Contents.json"),
'{\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n')

write(os.path.join(SRC, "Assets.xcassets", "AccentColor.colorset", "Contents.json"),
'{\n  "colors" : [\n    {\n      "idiom" : "universal"\n    }\n  ],\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n')

write(os.path.join(SRC, "Assets.xcassets", "AppIcon.appiconset", "Contents.json"),
'{\n  "images" : [\n    {\n      "idiom" : "universal",\n      "platform" : "ios",\n      "size" : "1024x1024"\n    }\n  ],\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n')

print(f"  detailsMatter.xcodeproj generated at {PROJ}")
print(f"   Open with: open \"{PROJ}\"")
print()
print("   NOTE: Download GoogleService-Info.plist from Firebase Console")
print(f"         and place it at: {os.path.join(SRC, 'GoogleService-Info.plist')}")
