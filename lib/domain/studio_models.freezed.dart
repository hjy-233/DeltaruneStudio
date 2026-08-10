// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'studio_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudioProject {

 int get schemaVersion; String get id; String get name; String get currentSceneId; List<Scene> get scenes; List<Character> get characters; List<AssetRef> get assets; EditorLayout get editorLayout; EditorSettings get settings;
/// Create a copy of StudioProject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudioProjectCopyWith<StudioProject> get copyWith => _$StudioProjectCopyWithImpl<StudioProject>(this as StudioProject, _$identity);

  /// Serializes this StudioProject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudioProject&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.currentSceneId, currentSceneId) || other.currentSceneId == currentSceneId)&&const DeepCollectionEquality().equals(other.scenes, scenes)&&const DeepCollectionEquality().equals(other.characters, characters)&&const DeepCollectionEquality().equals(other.assets, assets)&&(identical(other.editorLayout, editorLayout) || other.editorLayout == editorLayout)&&(identical(other.settings, settings) || other.settings == settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,id,name,currentSceneId,const DeepCollectionEquality().hash(scenes),const DeepCollectionEquality().hash(characters),const DeepCollectionEquality().hash(assets),editorLayout,settings);

@override
String toString() {
  return 'StudioProject(schemaVersion: $schemaVersion, id: $id, name: $name, currentSceneId: $currentSceneId, scenes: $scenes, characters: $characters, assets: $assets, editorLayout: $editorLayout, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $StudioProjectCopyWith<$Res>  {
  factory $StudioProjectCopyWith(StudioProject value, $Res Function(StudioProject) _then) = _$StudioProjectCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String id, String name, String currentSceneId, List<Scene> scenes, List<Character> characters, List<AssetRef> assets, EditorLayout editorLayout, EditorSettings settings
});


$EditorLayoutCopyWith<$Res> get editorLayout;$EditorSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$StudioProjectCopyWithImpl<$Res>
    implements $StudioProjectCopyWith<$Res> {
  _$StudioProjectCopyWithImpl(this._self, this._then);

  final StudioProject _self;
  final $Res Function(StudioProject) _then;

/// Create a copy of StudioProject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? id = null,Object? name = null,Object? currentSceneId = null,Object? scenes = null,Object? characters = null,Object? assets = null,Object? editorLayout = null,Object? settings = null,}) {
  return _then(StudioProject(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,currentSceneId: null == currentSceneId ? _self.currentSceneId : currentSceneId // ignore: cast_nullable_to_non_nullable
as String,scenes: null == scenes ? _self.scenes : scenes // ignore: cast_nullable_to_non_nullable
as List<Scene>,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as List<Character>,assets: null == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as List<AssetRef>,editorLayout: null == editorLayout ? _self.editorLayout : editorLayout // ignore: cast_nullable_to_non_nullable
as EditorLayout,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as EditorSettings,
  ));
}
/// Create a copy of StudioProject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditorLayoutCopyWith<$Res> get editorLayout {
  
  return $EditorLayoutCopyWith<$Res>(_self.editorLayout, (value) {
    return _then(_self.copyWith(editorLayout: value));
  });
}/// Create a copy of StudioProject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditorSettingsCopyWith<$Res> get settings {
  
  return $EditorSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [StudioProject].
extension StudioProjectPatterns on StudioProject {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudioProject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudioProject() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudioProject value)  $default,){
final _that = this;
switch (_that) {
case _StudioProject():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudioProject value)?  $default,){
final _that = this;
switch (_that) {
case _StudioProject() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String id,  String name,  String currentSceneId,  List<Scene> scenes,  List<Character> characters,  List<AssetRef> assets,  EditorLayout editorLayout,  EditorSettings settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudioProject() when $default != null:
return $default(_that.schemaVersion,_that.id,_that.name,_that.currentSceneId,_that.scenes,_that.characters,_that.assets,_that.editorLayout,_that.settings);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String id,  String name,  String currentSceneId,  List<Scene> scenes,  List<Character> characters,  List<AssetRef> assets,  EditorLayout editorLayout,  EditorSettings settings)  $default,) {final _that = this;
switch (_that) {
case _StudioProject():
return $default(_that.schemaVersion,_that.id,_that.name,_that.currentSceneId,_that.scenes,_that.characters,_that.assets,_that.editorLayout,_that.settings);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String id,  String name,  String currentSceneId,  List<Scene> scenes,  List<Character> characters,  List<AssetRef> assets,  EditorLayout editorLayout,  EditorSettings settings)?  $default,) {final _that = this;
switch (_that) {
case _StudioProject() when $default != null:
return $default(_that.schemaVersion,_that.id,_that.name,_that.currentSceneId,_that.scenes,_that.characters,_that.assets,_that.editorLayout,_that.settings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudioProject implements StudioProject {
  const _StudioProject({this.schemaVersion = 4, required this.id, required this.name, required this.currentSceneId, required  List<Scene> scenes, required  List<Character> characters, required  List<AssetRef> assets, this.editorLayout = const EditorLayout(), this.settings = const EditorSettings()}): _scenes = scenes,_characters = characters,_assets = assets;
  factory _StudioProject.fromJson(Map<String, dynamic> json) => _$StudioProjectFromJson(json);

@override@JsonKey() final  int schemaVersion;
@override final  String id;
@override final  String name;
@override final  String currentSceneId;
 final  List<Scene> _scenes;
@override List<Scene> get scenes {
  if (_scenes is EqualUnmodifiableListView) return _scenes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scenes);
}

 final  List<Character> _characters;
@override List<Character> get characters {
  if (_characters is EqualUnmodifiableListView) return _characters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_characters);
}

 final  List<AssetRef> _assets;
@override List<AssetRef> get assets {
  if (_assets is EqualUnmodifiableListView) return _assets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assets);
}

@override@JsonKey() final  EditorLayout editorLayout;
@override@JsonKey() final  EditorSettings settings;

/// Create a copy of StudioProject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudioProjectCopyWith<_StudioProject> get copyWith => __$StudioProjectCopyWithImpl<_StudioProject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudioProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudioProject&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.currentSceneId, currentSceneId) || other.currentSceneId == currentSceneId)&&const DeepCollectionEquality().equals(other._scenes, _scenes)&&const DeepCollectionEquality().equals(other._characters, _characters)&&const DeepCollectionEquality().equals(other._assets, _assets)&&(identical(other.editorLayout, editorLayout) || other.editorLayout == editorLayout)&&(identical(other.settings, settings) || other.settings == settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,id,name,currentSceneId,const DeepCollectionEquality().hash(_scenes),const DeepCollectionEquality().hash(_characters),const DeepCollectionEquality().hash(_assets),editorLayout,settings);

@override
String toString() {
  return 'StudioProject(schemaVersion: $schemaVersion, id: $id, name: $name, currentSceneId: $currentSceneId, scenes: $scenes, characters: $characters, assets: $assets, editorLayout: $editorLayout, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$StudioProjectCopyWith<$Res> implements $StudioProjectCopyWith<$Res> {
  factory _$StudioProjectCopyWith(_StudioProject value, $Res Function(_StudioProject) _then) = __$StudioProjectCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String id, String name, String currentSceneId, List<Scene> scenes, List<Character> characters, List<AssetRef> assets, EditorLayout editorLayout, EditorSettings settings
});


@override $EditorLayoutCopyWith<$Res> get editorLayout;@override $EditorSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class __$StudioProjectCopyWithImpl<$Res>
    implements _$StudioProjectCopyWith<$Res> {
  __$StudioProjectCopyWithImpl(this._self, this._then);

  final _StudioProject _self;
  final $Res Function(_StudioProject) _then;

/// Create a copy of StudioProject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? id = null,Object? name = null,Object? currentSceneId = null,Object? scenes = null,Object? characters = null,Object? assets = null,Object? editorLayout = null,Object? settings = null,}) {
  return _then(_StudioProject(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,currentSceneId: null == currentSceneId ? _self.currentSceneId : currentSceneId // ignore: cast_nullable_to_non_nullable
as String,scenes: null == scenes ? _self._scenes : scenes // ignore: cast_nullable_to_non_nullable
as List<Scene>,characters: null == characters ? _self._characters : characters // ignore: cast_nullable_to_non_nullable
as List<Character>,assets: null == assets ? _self._assets : assets // ignore: cast_nullable_to_non_nullable
as List<AssetRef>,editorLayout: null == editorLayout ? _self.editorLayout : editorLayout // ignore: cast_nullable_to_non_nullable
as EditorLayout,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as EditorSettings,
  ));
}

/// Create a copy of StudioProject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditorLayoutCopyWith<$Res> get editorLayout {
  
  return $EditorLayoutCopyWith<$Res>(_self.editorLayout, (value) {
    return _then(_self.copyWith(editorLayout: value));
  });
}/// Create a copy of StudioProject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditorSettingsCopyWith<$Res> get settings {
  
  return $EditorSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// @nodoc
mixin _$EditorLayout {

 double get leftSidebarWidth; double get rightSidebarWidth; double get bottomPanelHeight;
/// Create a copy of EditorLayout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorLayoutCopyWith<EditorLayout> get copyWith => _$EditorLayoutCopyWithImpl<EditorLayout>(this as EditorLayout, _$identity);

  /// Serializes this EditorLayout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorLayout&&(identical(other.leftSidebarWidth, leftSidebarWidth) || other.leftSidebarWidth == leftSidebarWidth)&&(identical(other.rightSidebarWidth, rightSidebarWidth) || other.rightSidebarWidth == rightSidebarWidth)&&(identical(other.bottomPanelHeight, bottomPanelHeight) || other.bottomPanelHeight == bottomPanelHeight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,leftSidebarWidth,rightSidebarWidth,bottomPanelHeight);

@override
String toString() {
  return 'EditorLayout(leftSidebarWidth: $leftSidebarWidth, rightSidebarWidth: $rightSidebarWidth, bottomPanelHeight: $bottomPanelHeight)';
}


}

/// @nodoc
abstract mixin class $EditorLayoutCopyWith<$Res>  {
  factory $EditorLayoutCopyWith(EditorLayout value, $Res Function(EditorLayout) _then) = _$EditorLayoutCopyWithImpl;
@useResult
$Res call({
 double leftSidebarWidth, double rightSidebarWidth, double bottomPanelHeight
});




}
/// @nodoc
class _$EditorLayoutCopyWithImpl<$Res>
    implements $EditorLayoutCopyWith<$Res> {
  _$EditorLayoutCopyWithImpl(this._self, this._then);

  final EditorLayout _self;
  final $Res Function(EditorLayout) _then;

/// Create a copy of EditorLayout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? leftSidebarWidth = null,Object? rightSidebarWidth = null,Object? bottomPanelHeight = null,}) {
  return _then(EditorLayout(
leftSidebarWidth: null == leftSidebarWidth ? _self.leftSidebarWidth : leftSidebarWidth // ignore: cast_nullable_to_non_nullable
as double,rightSidebarWidth: null == rightSidebarWidth ? _self.rightSidebarWidth : rightSidebarWidth // ignore: cast_nullable_to_non_nullable
as double,bottomPanelHeight: null == bottomPanelHeight ? _self.bottomPanelHeight : bottomPanelHeight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [EditorLayout].
extension EditorLayoutPatterns on EditorLayout {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorLayout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorLayout() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorLayout value)  $default,){
final _that = this;
switch (_that) {
case _EditorLayout():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorLayout value)?  $default,){
final _that = this;
switch (_that) {
case _EditorLayout() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double leftSidebarWidth,  double rightSidebarWidth,  double bottomPanelHeight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorLayout() when $default != null:
return $default(_that.leftSidebarWidth,_that.rightSidebarWidth,_that.bottomPanelHeight);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double leftSidebarWidth,  double rightSidebarWidth,  double bottomPanelHeight)  $default,) {final _that = this;
switch (_that) {
case _EditorLayout():
return $default(_that.leftSidebarWidth,_that.rightSidebarWidth,_that.bottomPanelHeight);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double leftSidebarWidth,  double rightSidebarWidth,  double bottomPanelHeight)?  $default,) {final _that = this;
switch (_that) {
case _EditorLayout() when $default != null:
return $default(_that.leftSidebarWidth,_that.rightSidebarWidth,_that.bottomPanelHeight);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EditorLayout implements EditorLayout {
  const _EditorLayout({this.leftSidebarWidth = 220, this.rightSidebarWidth = 280, this.bottomPanelHeight = 300});
  factory _EditorLayout.fromJson(Map<String, dynamic> json) => _$EditorLayoutFromJson(json);

@override@JsonKey() final  double leftSidebarWidth;
@override@JsonKey() final  double rightSidebarWidth;
@override@JsonKey() final  double bottomPanelHeight;

/// Create a copy of EditorLayout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorLayoutCopyWith<_EditorLayout> get copyWith => __$EditorLayoutCopyWithImpl<_EditorLayout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EditorLayoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorLayout&&(identical(other.leftSidebarWidth, leftSidebarWidth) || other.leftSidebarWidth == leftSidebarWidth)&&(identical(other.rightSidebarWidth, rightSidebarWidth) || other.rightSidebarWidth == rightSidebarWidth)&&(identical(other.bottomPanelHeight, bottomPanelHeight) || other.bottomPanelHeight == bottomPanelHeight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,leftSidebarWidth,rightSidebarWidth,bottomPanelHeight);

@override
String toString() {
  return 'EditorLayout(leftSidebarWidth: $leftSidebarWidth, rightSidebarWidth: $rightSidebarWidth, bottomPanelHeight: $bottomPanelHeight)';
}


}

/// @nodoc
abstract mixin class _$EditorLayoutCopyWith<$Res> implements $EditorLayoutCopyWith<$Res> {
  factory _$EditorLayoutCopyWith(_EditorLayout value, $Res Function(_EditorLayout) _then) = __$EditorLayoutCopyWithImpl;
@override @useResult
$Res call({
 double leftSidebarWidth, double rightSidebarWidth, double bottomPanelHeight
});




}
/// @nodoc
class __$EditorLayoutCopyWithImpl<$Res>
    implements _$EditorLayoutCopyWith<$Res> {
  __$EditorLayoutCopyWithImpl(this._self, this._then);

  final _EditorLayout _self;
  final $Res Function(_EditorLayout) _then;

/// Create a copy of EditorLayout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? leftSidebarWidth = null,Object? rightSidebarWidth = null,Object? bottomPanelHeight = null,}) {
  return _then(_EditorLayout(
leftSidebarWidth: null == leftSidebarWidth ? _self.leftSidebarWidth : leftSidebarWidth // ignore: cast_nullable_to_non_nullable
as double,rightSidebarWidth: null == rightSidebarWidth ? _self.rightSidebarWidth : rightSidebarWidth // ignore: cast_nullable_to_non_nullable
as double,bottomPanelHeight: null == bottomPanelHeight ? _self.bottomPanelHeight : bottomPanelHeight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$EditorSettings {

 AppLanguage get language; bool get englishDialogueTypewriterByWord;
/// Create a copy of EditorSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorSettingsCopyWith<EditorSettings> get copyWith => _$EditorSettingsCopyWithImpl<EditorSettings>(this as EditorSettings, _$identity);

  /// Serializes this EditorSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorSettings&&(identical(other.language, language) || other.language == language)&&(identical(other.englishDialogueTypewriterByWord, englishDialogueTypewriterByWord) || other.englishDialogueTypewriterByWord == englishDialogueTypewriterByWord));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,englishDialogueTypewriterByWord);

@override
String toString() {
  return 'EditorSettings(language: $language, englishDialogueTypewriterByWord: $englishDialogueTypewriterByWord)';
}


}

/// @nodoc
abstract mixin class $EditorSettingsCopyWith<$Res>  {
  factory $EditorSettingsCopyWith(EditorSettings value, $Res Function(EditorSettings) _then) = _$EditorSettingsCopyWithImpl;
@useResult
$Res call({
 AppLanguage language, bool englishDialogueTypewriterByWord
});




}
/// @nodoc
class _$EditorSettingsCopyWithImpl<$Res>
    implements $EditorSettingsCopyWith<$Res> {
  _$EditorSettingsCopyWithImpl(this._self, this._then);

  final EditorSettings _self;
  final $Res Function(EditorSettings) _then;

/// Create a copy of EditorSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,Object? englishDialogueTypewriterByWord = null,}) {
  return _then(EditorSettings(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,englishDialogueTypewriterByWord: null == englishDialogueTypewriterByWord ? _self.englishDialogueTypewriterByWord : englishDialogueTypewriterByWord // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EditorSettings].
extension EditorSettingsPatterns on EditorSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorSettings value)  $default,){
final _that = this;
switch (_that) {
case _EditorSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorSettings value)?  $default,){
final _that = this;
switch (_that) {
case _EditorSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppLanguage language,  bool englishDialogueTypewriterByWord)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorSettings() when $default != null:
return $default(_that.language,_that.englishDialogueTypewriterByWord);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppLanguage language,  bool englishDialogueTypewriterByWord)  $default,) {final _that = this;
switch (_that) {
case _EditorSettings():
return $default(_that.language,_that.englishDialogueTypewriterByWord);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppLanguage language,  bool englishDialogueTypewriterByWord)?  $default,) {final _that = this;
switch (_that) {
case _EditorSettings() when $default != null:
return $default(_that.language,_that.englishDialogueTypewriterByWord);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EditorSettings implements EditorSettings {
  const _EditorSettings({this.language = AppLanguage.system, this.englishDialogueTypewriterByWord = true});
  factory _EditorSettings.fromJson(Map<String, dynamic> json) => _$EditorSettingsFromJson(json);

@override@JsonKey() final  AppLanguage language;
@override@JsonKey() final  bool englishDialogueTypewriterByWord;

/// Create a copy of EditorSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorSettingsCopyWith<_EditorSettings> get copyWith => __$EditorSettingsCopyWithImpl<_EditorSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EditorSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorSettings&&(identical(other.language, language) || other.language == language)&&(identical(other.englishDialogueTypewriterByWord, englishDialogueTypewriterByWord) || other.englishDialogueTypewriterByWord == englishDialogueTypewriterByWord));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,englishDialogueTypewriterByWord);

@override
String toString() {
  return 'EditorSettings(language: $language, englishDialogueTypewriterByWord: $englishDialogueTypewriterByWord)';
}


}

/// @nodoc
abstract mixin class _$EditorSettingsCopyWith<$Res> implements $EditorSettingsCopyWith<$Res> {
  factory _$EditorSettingsCopyWith(_EditorSettings value, $Res Function(_EditorSettings) _then) = __$EditorSettingsCopyWithImpl;
@override @useResult
$Res call({
 AppLanguage language, bool englishDialogueTypewriterByWord
});




}
/// @nodoc
class __$EditorSettingsCopyWithImpl<$Res>
    implements _$EditorSettingsCopyWith<$Res> {
  __$EditorSettingsCopyWithImpl(this._self, this._then);

  final _EditorSettings _self;
  final $Res Function(_EditorSettings) _then;

/// Create a copy of EditorSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,Object? englishDialogueTypewriterByWord = null,}) {
  return _then(_EditorSettings(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,englishDialogueTypewriterByWord: null == englishDialogueTypewriterByWord ? _self.englishDialogueTypewriterByWord : englishDialogueTypewriterByWord // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AssetRef {

 String get id;@JsonKey(unknownEnumValue: AssetKind.prop) AssetKind get kind; String get relativePath; String get originalName; String? get dataUri;
/// Create a copy of AssetRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetRefCopyWith<AssetRef> get copyWith => _$AssetRefCopyWithImpl<AssetRef>(this as AssetRef, _$identity);

  /// Serializes this AssetRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetRef&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.relativePath, relativePath) || other.relativePath == relativePath)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.dataUri, dataUri) || other.dataUri == dataUri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,relativePath,originalName,dataUri);

@override
String toString() {
  return 'AssetRef(id: $id, kind: $kind, relativePath: $relativePath, originalName: $originalName, dataUri: $dataUri)';
}


}

/// @nodoc
abstract mixin class $AssetRefCopyWith<$Res>  {
  factory $AssetRefCopyWith(AssetRef value, $Res Function(AssetRef) _then) = _$AssetRefCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: AssetKind.prop) AssetKind kind, String relativePath, String originalName, String? dataUri
});




}
/// @nodoc
class _$AssetRefCopyWithImpl<$Res>
    implements $AssetRefCopyWith<$Res> {
  _$AssetRefCopyWithImpl(this._self, this._then);

  final AssetRef _self;
  final $Res Function(AssetRef) _then;

/// Create a copy of AssetRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? relativePath = null,Object? originalName = null,Object? dataUri = freezed,}) {
  return _then(AssetRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AssetKind,relativePath: null == relativePath ? _self.relativePath : relativePath // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,dataUri: freezed == dataUri ? _self.dataUri : dataUri // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetRef].
extension AssetRefPatterns on AssetRef {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetRef() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetRef value)  $default,){
final _that = this;
switch (_that) {
case _AssetRef():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetRef value)?  $default,){
final _that = this;
switch (_that) {
case _AssetRef() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: AssetKind.prop)  AssetKind kind,  String relativePath,  String originalName,  String? dataUri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetRef() when $default != null:
return $default(_that.id,_that.kind,_that.relativePath,_that.originalName,_that.dataUri);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: AssetKind.prop)  AssetKind kind,  String relativePath,  String originalName,  String? dataUri)  $default,) {final _that = this;
switch (_that) {
case _AssetRef():
return $default(_that.id,_that.kind,_that.relativePath,_that.originalName,_that.dataUri);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: AssetKind.prop)  AssetKind kind,  String relativePath,  String originalName,  String? dataUri)?  $default,) {final _that = this;
switch (_that) {
case _AssetRef() when $default != null:
return $default(_that.id,_that.kind,_that.relativePath,_that.originalName,_that.dataUri);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssetRef implements AssetRef {
  const _AssetRef({required this.id, @JsonKey(unknownEnumValue: AssetKind.prop) required this.kind, required this.relativePath, required this.originalName, this.dataUri});
  factory _AssetRef.fromJson(Map<String, dynamic> json) => _$AssetRefFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: AssetKind.prop) final  AssetKind kind;
@override final  String relativePath;
@override final  String originalName;
@override final  String? dataUri;

/// Create a copy of AssetRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetRefCopyWith<_AssetRef> get copyWith => __$AssetRefCopyWithImpl<_AssetRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssetRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetRef&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.relativePath, relativePath) || other.relativePath == relativePath)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.dataUri, dataUri) || other.dataUri == dataUri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,relativePath,originalName,dataUri);

@override
String toString() {
  return 'AssetRef(id: $id, kind: $kind, relativePath: $relativePath, originalName: $originalName, dataUri: $dataUri)';
}


}

/// @nodoc
abstract mixin class _$AssetRefCopyWith<$Res> implements $AssetRefCopyWith<$Res> {
  factory _$AssetRefCopyWith(_AssetRef value, $Res Function(_AssetRef) _then) = __$AssetRefCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: AssetKind.prop) AssetKind kind, String relativePath, String originalName, String? dataUri
});




}
/// @nodoc
class __$AssetRefCopyWithImpl<$Res>
    implements _$AssetRefCopyWith<$Res> {
  __$AssetRefCopyWithImpl(this._self, this._then);

  final _AssetRef _self;
  final $Res Function(_AssetRef) _then;

/// Create a copy of AssetRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? relativePath = null,Object? originalName = null,Object? dataUri = freezed,}) {
  return _then(_AssetRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AssetKind,relativePath: null == relativePath ? _self.relativePath : relativePath // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,dataUri: freezed == dataUri ? _self.dataUri : dataUri // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Scene {

 String get id; String get name; String? get backgroundAssetId; List<SceneObject> get objects; List<Trigger> get triggers; List<EventChain> get eventChains; List<InterestPoint> get interestPoints; CameraPolicy get cameraPolicy;
/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneCopyWith<Scene> get copyWith => _$SceneCopyWithImpl<Scene>(this as Scene, _$identity);

  /// Serializes this Scene to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scene&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.backgroundAssetId, backgroundAssetId) || other.backgroundAssetId == backgroundAssetId)&&const DeepCollectionEquality().equals(other.objects, objects)&&const DeepCollectionEquality().equals(other.triggers, triggers)&&const DeepCollectionEquality().equals(other.eventChains, eventChains)&&const DeepCollectionEquality().equals(other.interestPoints, interestPoints)&&(identical(other.cameraPolicy, cameraPolicy) || other.cameraPolicy == cameraPolicy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,backgroundAssetId,const DeepCollectionEquality().hash(objects),const DeepCollectionEquality().hash(triggers),const DeepCollectionEquality().hash(eventChains),const DeepCollectionEquality().hash(interestPoints),cameraPolicy);

@override
String toString() {
  return 'Scene(id: $id, name: $name, backgroundAssetId: $backgroundAssetId, objects: $objects, triggers: $triggers, eventChains: $eventChains, interestPoints: $interestPoints, cameraPolicy: $cameraPolicy)';
}


}

/// @nodoc
abstract mixin class $SceneCopyWith<$Res>  {
  factory $SceneCopyWith(Scene value, $Res Function(Scene) _then) = _$SceneCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? backgroundAssetId, List<SceneObject> objects, List<Trigger> triggers, List<EventChain> eventChains, List<InterestPoint> interestPoints, CameraPolicy cameraPolicy
});


$CameraPolicyCopyWith<$Res> get cameraPolicy;

}
/// @nodoc
class _$SceneCopyWithImpl<$Res>
    implements $SceneCopyWith<$Res> {
  _$SceneCopyWithImpl(this._self, this._then);

  final Scene _self;
  final $Res Function(Scene) _then;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? backgroundAssetId = freezed,Object? objects = null,Object? triggers = null,Object? eventChains = null,Object? interestPoints = null,Object? cameraPolicy = null,}) {
  return _then(Scene(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,backgroundAssetId: freezed == backgroundAssetId ? _self.backgroundAssetId : backgroundAssetId // ignore: cast_nullable_to_non_nullable
as String?,objects: null == objects ? _self.objects : objects // ignore: cast_nullable_to_non_nullable
as List<SceneObject>,triggers: null == triggers ? _self.triggers : triggers // ignore: cast_nullable_to_non_nullable
as List<Trigger>,eventChains: null == eventChains ? _self.eventChains : eventChains // ignore: cast_nullable_to_non_nullable
as List<EventChain>,interestPoints: null == interestPoints ? _self.interestPoints : interestPoints // ignore: cast_nullable_to_non_nullable
as List<InterestPoint>,cameraPolicy: null == cameraPolicy ? _self.cameraPolicy : cameraPolicy // ignore: cast_nullable_to_non_nullable
as CameraPolicy,
  ));
}
/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CameraPolicyCopyWith<$Res> get cameraPolicy {
  
  return $CameraPolicyCopyWith<$Res>(_self.cameraPolicy, (value) {
    return _then(_self.copyWith(cameraPolicy: value));
  });
}
}


/// Adds pattern-matching-related methods to [Scene].
extension ScenePatterns on Scene {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Scene value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Scene value)  $default,){
final _that = this;
switch (_that) {
case _Scene():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Scene value)?  $default,){
final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? backgroundAssetId,  List<SceneObject> objects,  List<Trigger> triggers,  List<EventChain> eventChains,  List<InterestPoint> interestPoints,  CameraPolicy cameraPolicy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that.id,_that.name,_that.backgroundAssetId,_that.objects,_that.triggers,_that.eventChains,_that.interestPoints,_that.cameraPolicy);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? backgroundAssetId,  List<SceneObject> objects,  List<Trigger> triggers,  List<EventChain> eventChains,  List<InterestPoint> interestPoints,  CameraPolicy cameraPolicy)  $default,) {final _that = this;
switch (_that) {
case _Scene():
return $default(_that.id,_that.name,_that.backgroundAssetId,_that.objects,_that.triggers,_that.eventChains,_that.interestPoints,_that.cameraPolicy);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? backgroundAssetId,  List<SceneObject> objects,  List<Trigger> triggers,  List<EventChain> eventChains,  List<InterestPoint> interestPoints,  CameraPolicy cameraPolicy)?  $default,) {final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that.id,_that.name,_that.backgroundAssetId,_that.objects,_that.triggers,_that.eventChains,_that.interestPoints,_that.cameraPolicy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Scene implements Scene {
  const _Scene({required this.id, required this.name, this.backgroundAssetId, required  List<SceneObject> objects, required  List<Trigger> triggers, required  List<EventChain> eventChains, required  List<InterestPoint> interestPoints, required this.cameraPolicy}): _objects = objects,_triggers = triggers,_eventChains = eventChains,_interestPoints = interestPoints;
  factory _Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? backgroundAssetId;
 final  List<SceneObject> _objects;
@override List<SceneObject> get objects {
  if (_objects is EqualUnmodifiableListView) return _objects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_objects);
}

 final  List<Trigger> _triggers;
@override List<Trigger> get triggers {
  if (_triggers is EqualUnmodifiableListView) return _triggers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_triggers);
}

 final  List<EventChain> _eventChains;
@override List<EventChain> get eventChains {
  if (_eventChains is EqualUnmodifiableListView) return _eventChains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_eventChains);
}

 final  List<InterestPoint> _interestPoints;
@override List<InterestPoint> get interestPoints {
  if (_interestPoints is EqualUnmodifiableListView) return _interestPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interestPoints);
}

@override final  CameraPolicy cameraPolicy;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneCopyWith<_Scene> get copyWith => __$SceneCopyWithImpl<_Scene>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scene&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.backgroundAssetId, backgroundAssetId) || other.backgroundAssetId == backgroundAssetId)&&const DeepCollectionEquality().equals(other._objects, _objects)&&const DeepCollectionEquality().equals(other._triggers, _triggers)&&const DeepCollectionEquality().equals(other._eventChains, _eventChains)&&const DeepCollectionEquality().equals(other._interestPoints, _interestPoints)&&(identical(other.cameraPolicy, cameraPolicy) || other.cameraPolicy == cameraPolicy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,backgroundAssetId,const DeepCollectionEquality().hash(_objects),const DeepCollectionEquality().hash(_triggers),const DeepCollectionEquality().hash(_eventChains),const DeepCollectionEquality().hash(_interestPoints),cameraPolicy);

@override
String toString() {
  return 'Scene(id: $id, name: $name, backgroundAssetId: $backgroundAssetId, objects: $objects, triggers: $triggers, eventChains: $eventChains, interestPoints: $interestPoints, cameraPolicy: $cameraPolicy)';
}


}

/// @nodoc
abstract mixin class _$SceneCopyWith<$Res> implements $SceneCopyWith<$Res> {
  factory _$SceneCopyWith(_Scene value, $Res Function(_Scene) _then) = __$SceneCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? backgroundAssetId, List<SceneObject> objects, List<Trigger> triggers, List<EventChain> eventChains, List<InterestPoint> interestPoints, CameraPolicy cameraPolicy
});


@override $CameraPolicyCopyWith<$Res> get cameraPolicy;

}
/// @nodoc
class __$SceneCopyWithImpl<$Res>
    implements _$SceneCopyWith<$Res> {
  __$SceneCopyWithImpl(this._self, this._then);

  final _Scene _self;
  final $Res Function(_Scene) _then;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? backgroundAssetId = freezed,Object? objects = null,Object? triggers = null,Object? eventChains = null,Object? interestPoints = null,Object? cameraPolicy = null,}) {
  return _then(_Scene(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,backgroundAssetId: freezed == backgroundAssetId ? _self.backgroundAssetId : backgroundAssetId // ignore: cast_nullable_to_non_nullable
as String?,objects: null == objects ? _self._objects : objects // ignore: cast_nullable_to_non_nullable
as List<SceneObject>,triggers: null == triggers ? _self._triggers : triggers // ignore: cast_nullable_to_non_nullable
as List<Trigger>,eventChains: null == eventChains ? _self._eventChains : eventChains // ignore: cast_nullable_to_non_nullable
as List<EventChain>,interestPoints: null == interestPoints ? _self._interestPoints : interestPoints // ignore: cast_nullable_to_non_nullable
as List<InterestPoint>,cameraPolicy: null == cameraPolicy ? _self.cameraPolicy : cameraPolicy // ignore: cast_nullable_to_non_nullable
as CameraPolicy,
  ));
}

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CameraPolicyCopyWith<$Res> get cameraPolicy {
  
  return $CameraPolicyCopyWith<$Res>(_self.cameraPolicy, (value) {
    return _then(_self.copyWith(cameraPolicy: value));
  });
}
}

SceneObject _$SceneObjectFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'characterInstance':
          return CharacterInstanceObject.fromJson(
            json
          );
                case 'prop':
          return PropSceneObject.fromJson(
            json
          );
                case 'background':
          return BackgroundObject.fromJson(
            json
          );
                case 'triggerPoint':
          return TriggerPointObject.fromJson(
            json
          );
                case 'triggerArea':
          return TriggerAreaObject.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'SceneObject',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$SceneObject {

 String get id; String get name; Transform2D get transform; bool get locked;
/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneObjectCopyWith<SceneObject> get copyWith => _$SceneObjectCopyWithImpl<SceneObject>(this as SceneObject, _$identity);

  /// Serializes this SceneObject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneObject&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.locked, locked) || other.locked == locked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,transform,locked);

@override
String toString() {
  return 'SceneObject(id: $id, name: $name, transform: $transform, locked: $locked)';
}


}

/// @nodoc
abstract mixin class $SceneObjectCopyWith<$Res>  {
  factory $SceneObjectCopyWith(SceneObject value, $Res Function(SceneObject) _then) = _$SceneObjectCopyWithImpl;
@useResult
$Res call({
 String id, String name, Transform2D transform, bool locked
});


$Transform2DCopyWith<$Res> get transform;

}
/// @nodoc
class _$SceneObjectCopyWithImpl<$Res>
    implements $SceneObjectCopyWith<$Res> {
  _$SceneObjectCopyWithImpl(this._self, this._then);

  final SceneObject _self;
  final $Res Function(SceneObject) _then;

/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? transform = null,Object? locked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Transform2D,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Transform2DCopyWith<$Res> get transform {
  
  return $Transform2DCopyWith<$Res>(_self.transform, (value) {
    return _then(_self.copyWith(transform: value));
  });
}
}


/// Adds pattern-matching-related methods to [SceneObject].
extension SceneObjectPatterns on SceneObject {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CharacterInstanceObject value)?  characterInstance,TResult Function( PropSceneObject value)?  prop,TResult Function( BackgroundObject value)?  background,TResult Function( TriggerPointObject value)?  triggerPoint,TResult Function( TriggerAreaObject value)?  triggerArea,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CharacterInstanceObject() when characterInstance != null:
return characterInstance(_that);case PropSceneObject() when prop != null:
return prop(_that);case BackgroundObject() when background != null:
return background(_that);case TriggerPointObject() when triggerPoint != null:
return triggerPoint(_that);case TriggerAreaObject() when triggerArea != null:
return triggerArea(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CharacterInstanceObject value)  characterInstance,required TResult Function( PropSceneObject value)  prop,required TResult Function( BackgroundObject value)  background,required TResult Function( TriggerPointObject value)  triggerPoint,required TResult Function( TriggerAreaObject value)  triggerArea,}){
final _that = this;
switch (_that) {
case CharacterInstanceObject():
return characterInstance(_that);case PropSceneObject():
return prop(_that);case BackgroundObject():
return background(_that);case TriggerPointObject():
return triggerPoint(_that);case TriggerAreaObject():
return triggerArea(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CharacterInstanceObject value)?  characterInstance,TResult? Function( PropSceneObject value)?  prop,TResult? Function( BackgroundObject value)?  background,TResult? Function( TriggerPointObject value)?  triggerPoint,TResult? Function( TriggerAreaObject value)?  triggerArea,}){
final _that = this;
switch (_that) {
case CharacterInstanceObject() when characterInstance != null:
return characterInstance(_that);case PropSceneObject() when prop != null:
return prop(_that);case BackgroundObject() when background != null:
return background(_that);case TriggerPointObject() when triggerPoint != null:
return triggerPoint(_that);case TriggerAreaObject() when triggerArea != null:
return triggerArea(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String name,  String characterId,  Transform2D transform,  Direction facing,  String? initialExpression,  ActivityProfile? activity,  bool locked)?  characterInstance,TResult Function( String id,  String name,  String assetId,  Transform2D transform,  bool interactable,  bool locked)?  prop,TResult Function( String id,  String name,  String assetId,  Transform2D transform,  bool locked)?  background,TResult Function( String id,  String name,  String triggerId,  Transform2D transform,  bool locked)?  triggerPoint,TResult Function( String id,  String name,  String triggerId,  Transform2D transform,  bool locked)?  triggerArea,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CharacterInstanceObject() when characterInstance != null:
return characterInstance(_that.id,_that.name,_that.characterId,_that.transform,_that.facing,_that.initialExpression,_that.activity,_that.locked);case PropSceneObject() when prop != null:
return prop(_that.id,_that.name,_that.assetId,_that.transform,_that.interactable,_that.locked);case BackgroundObject() when background != null:
return background(_that.id,_that.name,_that.assetId,_that.transform,_that.locked);case TriggerPointObject() when triggerPoint != null:
return triggerPoint(_that.id,_that.name,_that.triggerId,_that.transform,_that.locked);case TriggerAreaObject() when triggerArea != null:
return triggerArea(_that.id,_that.name,_that.triggerId,_that.transform,_that.locked);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String name,  String characterId,  Transform2D transform,  Direction facing,  String? initialExpression,  ActivityProfile? activity,  bool locked)  characterInstance,required TResult Function( String id,  String name,  String assetId,  Transform2D transform,  bool interactable,  bool locked)  prop,required TResult Function( String id,  String name,  String assetId,  Transform2D transform,  bool locked)  background,required TResult Function( String id,  String name,  String triggerId,  Transform2D transform,  bool locked)  triggerPoint,required TResult Function( String id,  String name,  String triggerId,  Transform2D transform,  bool locked)  triggerArea,}) {final _that = this;
switch (_that) {
case CharacterInstanceObject():
return characterInstance(_that.id,_that.name,_that.characterId,_that.transform,_that.facing,_that.initialExpression,_that.activity,_that.locked);case PropSceneObject():
return prop(_that.id,_that.name,_that.assetId,_that.transform,_that.interactable,_that.locked);case BackgroundObject():
return background(_that.id,_that.name,_that.assetId,_that.transform,_that.locked);case TriggerPointObject():
return triggerPoint(_that.id,_that.name,_that.triggerId,_that.transform,_that.locked);case TriggerAreaObject():
return triggerArea(_that.id,_that.name,_that.triggerId,_that.transform,_that.locked);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String name,  String characterId,  Transform2D transform,  Direction facing,  String? initialExpression,  ActivityProfile? activity,  bool locked)?  characterInstance,TResult? Function( String id,  String name,  String assetId,  Transform2D transform,  bool interactable,  bool locked)?  prop,TResult? Function( String id,  String name,  String assetId,  Transform2D transform,  bool locked)?  background,TResult? Function( String id,  String name,  String triggerId,  Transform2D transform,  bool locked)?  triggerPoint,TResult? Function( String id,  String name,  String triggerId,  Transform2D transform,  bool locked)?  triggerArea,}) {final _that = this;
switch (_that) {
case CharacterInstanceObject() when characterInstance != null:
return characterInstance(_that.id,_that.name,_that.characterId,_that.transform,_that.facing,_that.initialExpression,_that.activity,_that.locked);case PropSceneObject() when prop != null:
return prop(_that.id,_that.name,_that.assetId,_that.transform,_that.interactable,_that.locked);case BackgroundObject() when background != null:
return background(_that.id,_that.name,_that.assetId,_that.transform,_that.locked);case TriggerPointObject() when triggerPoint != null:
return triggerPoint(_that.id,_that.name,_that.triggerId,_that.transform,_that.locked);case TriggerAreaObject() when triggerArea != null:
return triggerArea(_that.id,_that.name,_that.triggerId,_that.transform,_that.locked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class CharacterInstanceObject extends SceneObject {
  const CharacterInstanceObject({required this.id, required this.name, required this.characterId, required this.transform, required this.facing, this.initialExpression, this.activity, this.locked = false,  String? $type}): $type = $type ?? 'characterInstance',super._();
  factory CharacterInstanceObject.fromJson(Map<String, dynamic> json) => _$CharacterInstanceObjectFromJson(json);

@override final  String id;
@override final  String name;
 final  String characterId;
@override final  Transform2D transform;
 final  Direction facing;
 final  String? initialExpression;
 final  ActivityProfile? activity;
@override@JsonKey() final  bool locked;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterInstanceObjectCopyWith<CharacterInstanceObject> get copyWith => _$CharacterInstanceObjectCopyWithImpl<CharacterInstanceObject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CharacterInstanceObjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CharacterInstanceObject&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.characterId, characterId) || other.characterId == characterId)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.facing, facing) || other.facing == facing)&&(identical(other.initialExpression, initialExpression) || other.initialExpression == initialExpression)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.locked, locked) || other.locked == locked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,characterId,transform,facing,initialExpression,activity,locked);

@override
String toString() {
  return 'SceneObject.characterInstance(id: $id, name: $name, characterId: $characterId, transform: $transform, facing: $facing, initialExpression: $initialExpression, activity: $activity, locked: $locked)';
}


}

/// @nodoc
abstract mixin class $CharacterInstanceObjectCopyWith<$Res> implements $SceneObjectCopyWith<$Res> {
  factory $CharacterInstanceObjectCopyWith(CharacterInstanceObject value, $Res Function(CharacterInstanceObject) _then) = _$CharacterInstanceObjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String characterId, Transform2D transform, Direction facing, String? initialExpression, ActivityProfile? activity, bool locked
});


@override $Transform2DCopyWith<$Res> get transform;$ActivityProfileCopyWith<$Res>? get activity;

}
/// @nodoc
class _$CharacterInstanceObjectCopyWithImpl<$Res>
    implements $CharacterInstanceObjectCopyWith<$Res> {
  _$CharacterInstanceObjectCopyWithImpl(this._self, this._then);

  final CharacterInstanceObject _self;
  final $Res Function(CharacterInstanceObject) _then;

/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? characterId = null,Object? transform = null,Object? facing = null,Object? initialExpression = freezed,Object? activity = freezed,Object? locked = null,}) {
  return _then(CharacterInstanceObject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,characterId: null == characterId ? _self.characterId : characterId // ignore: cast_nullable_to_non_nullable
as String,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Transform2D,facing: null == facing ? _self.facing : facing // ignore: cast_nullable_to_non_nullable
as Direction,initialExpression: freezed == initialExpression ? _self.initialExpression : initialExpression // ignore: cast_nullable_to_non_nullable
as String?,activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ActivityProfile?,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Transform2DCopyWith<$Res> get transform {
  
  return $Transform2DCopyWith<$Res>(_self.transform, (value) {
    return _then(_self.copyWith(transform: value));
  });
}/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActivityProfileCopyWith<$Res>? get activity {
    if (_self.activity == null) {
    return null;
  }

  return $ActivityProfileCopyWith<$Res>(_self.activity!, (value) {
    return _then(_self.copyWith(activity: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class PropSceneObject extends SceneObject {
  const PropSceneObject({required this.id, required this.name, required this.assetId, required this.transform, this.interactable = false, this.locked = false,  String? $type}): $type = $type ?? 'prop',super._();
  factory PropSceneObject.fromJson(Map<String, dynamic> json) => _$PropSceneObjectFromJson(json);

@override final  String id;
@override final  String name;
 final  String assetId;
@override final  Transform2D transform;
@JsonKey() final  bool interactable;
@override@JsonKey() final  bool locked;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropSceneObjectCopyWith<PropSceneObject> get copyWith => _$PropSceneObjectCopyWithImpl<PropSceneObject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PropSceneObjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PropSceneObject&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.interactable, interactable) || other.interactable == interactable)&&(identical(other.locked, locked) || other.locked == locked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,assetId,transform,interactable,locked);

@override
String toString() {
  return 'SceneObject.prop(id: $id, name: $name, assetId: $assetId, transform: $transform, interactable: $interactable, locked: $locked)';
}


}

/// @nodoc
abstract mixin class $PropSceneObjectCopyWith<$Res> implements $SceneObjectCopyWith<$Res> {
  factory $PropSceneObjectCopyWith(PropSceneObject value, $Res Function(PropSceneObject) _then) = _$PropSceneObjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String assetId, Transform2D transform, bool interactable, bool locked
});


@override $Transform2DCopyWith<$Res> get transform;

}
/// @nodoc
class _$PropSceneObjectCopyWithImpl<$Res>
    implements $PropSceneObjectCopyWith<$Res> {
  _$PropSceneObjectCopyWithImpl(this._self, this._then);

  final PropSceneObject _self;
  final $Res Function(PropSceneObject) _then;

/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? assetId = null,Object? transform = null,Object? interactable = null,Object? locked = null,}) {
  return _then(PropSceneObject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Transform2D,interactable: null == interactable ? _self.interactable : interactable // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Transform2DCopyWith<$Res> get transform {
  
  return $Transform2DCopyWith<$Res>(_self.transform, (value) {
    return _then(_self.copyWith(transform: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class BackgroundObject extends SceneObject {
  const BackgroundObject({required this.id, required this.name, required this.assetId, required this.transform, this.locked = false,  String? $type}): $type = $type ?? 'background',super._();
  factory BackgroundObject.fromJson(Map<String, dynamic> json) => _$BackgroundObjectFromJson(json);

@override final  String id;
@override final  String name;
 final  String assetId;
@override final  Transform2D transform;
@override@JsonKey() final  bool locked;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackgroundObjectCopyWith<BackgroundObject> get copyWith => _$BackgroundObjectCopyWithImpl<BackgroundObject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BackgroundObjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackgroundObject&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.locked, locked) || other.locked == locked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,assetId,transform,locked);

@override
String toString() {
  return 'SceneObject.background(id: $id, name: $name, assetId: $assetId, transform: $transform, locked: $locked)';
}


}

/// @nodoc
abstract mixin class $BackgroundObjectCopyWith<$Res> implements $SceneObjectCopyWith<$Res> {
  factory $BackgroundObjectCopyWith(BackgroundObject value, $Res Function(BackgroundObject) _then) = _$BackgroundObjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String assetId, Transform2D transform, bool locked
});


@override $Transform2DCopyWith<$Res> get transform;

}
/// @nodoc
class _$BackgroundObjectCopyWithImpl<$Res>
    implements $BackgroundObjectCopyWith<$Res> {
  _$BackgroundObjectCopyWithImpl(this._self, this._then);

  final BackgroundObject _self;
  final $Res Function(BackgroundObject) _then;

/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? assetId = null,Object? transform = null,Object? locked = null,}) {
  return _then(BackgroundObject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Transform2D,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Transform2DCopyWith<$Res> get transform {
  
  return $Transform2DCopyWith<$Res>(_self.transform, (value) {
    return _then(_self.copyWith(transform: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class TriggerPointObject extends SceneObject {
  const TriggerPointObject({required this.id, required this.name, required this.triggerId, required this.transform, this.locked = false,  String? $type}): $type = $type ?? 'triggerPoint',super._();
  factory TriggerPointObject.fromJson(Map<String, dynamic> json) => _$TriggerPointObjectFromJson(json);

@override final  String id;
@override final  String name;
 final  String triggerId;
@override final  Transform2D transform;
@override@JsonKey() final  bool locked;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TriggerPointObjectCopyWith<TriggerPointObject> get copyWith => _$TriggerPointObjectCopyWithImpl<TriggerPointObject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TriggerPointObjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TriggerPointObject&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.triggerId, triggerId) || other.triggerId == triggerId)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.locked, locked) || other.locked == locked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,triggerId,transform,locked);

@override
String toString() {
  return 'SceneObject.triggerPoint(id: $id, name: $name, triggerId: $triggerId, transform: $transform, locked: $locked)';
}


}

/// @nodoc
abstract mixin class $TriggerPointObjectCopyWith<$Res> implements $SceneObjectCopyWith<$Res> {
  factory $TriggerPointObjectCopyWith(TriggerPointObject value, $Res Function(TriggerPointObject) _then) = _$TriggerPointObjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String triggerId, Transform2D transform, bool locked
});


@override $Transform2DCopyWith<$Res> get transform;

}
/// @nodoc
class _$TriggerPointObjectCopyWithImpl<$Res>
    implements $TriggerPointObjectCopyWith<$Res> {
  _$TriggerPointObjectCopyWithImpl(this._self, this._then);

  final TriggerPointObject _self;
  final $Res Function(TriggerPointObject) _then;

/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? triggerId = null,Object? transform = null,Object? locked = null,}) {
  return _then(TriggerPointObject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,triggerId: null == triggerId ? _self.triggerId : triggerId // ignore: cast_nullable_to_non_nullable
as String,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Transform2D,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Transform2DCopyWith<$Res> get transform {
  
  return $Transform2DCopyWith<$Res>(_self.transform, (value) {
    return _then(_self.copyWith(transform: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class TriggerAreaObject extends SceneObject {
  const TriggerAreaObject({required this.id, required this.name, required this.triggerId, required this.transform, this.locked = false,  String? $type}): $type = $type ?? 'triggerArea',super._();
  factory TriggerAreaObject.fromJson(Map<String, dynamic> json) => _$TriggerAreaObjectFromJson(json);

@override final  String id;
@override final  String name;
 final  String triggerId;
@override final  Transform2D transform;
@override@JsonKey() final  bool locked;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TriggerAreaObjectCopyWith<TriggerAreaObject> get copyWith => _$TriggerAreaObjectCopyWithImpl<TriggerAreaObject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TriggerAreaObjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TriggerAreaObject&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.triggerId, triggerId) || other.triggerId == triggerId)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.locked, locked) || other.locked == locked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,triggerId,transform,locked);

@override
String toString() {
  return 'SceneObject.triggerArea(id: $id, name: $name, triggerId: $triggerId, transform: $transform, locked: $locked)';
}


}

/// @nodoc
abstract mixin class $TriggerAreaObjectCopyWith<$Res> implements $SceneObjectCopyWith<$Res> {
  factory $TriggerAreaObjectCopyWith(TriggerAreaObject value, $Res Function(TriggerAreaObject) _then) = _$TriggerAreaObjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String triggerId, Transform2D transform, bool locked
});


@override $Transform2DCopyWith<$Res> get transform;

}
/// @nodoc
class _$TriggerAreaObjectCopyWithImpl<$Res>
    implements $TriggerAreaObjectCopyWith<$Res> {
  _$TriggerAreaObjectCopyWithImpl(this._self, this._then);

  final TriggerAreaObject _self;
  final $Res Function(TriggerAreaObject) _then;

/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? triggerId = null,Object? transform = null,Object? locked = null,}) {
  return _then(TriggerAreaObject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,triggerId: null == triggerId ? _self.triggerId : triggerId // ignore: cast_nullable_to_non_nullable
as String,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as Transform2D,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SceneObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Transform2DCopyWith<$Res> get transform {
  
  return $Transform2DCopyWith<$Res>(_self.transform, (value) {
    return _then(_self.copyWith(transform: value));
  });
}
}


/// @nodoc
mixin _$Transform2D {

 double get x; double get y; double get width; double get height; double get scale; double get rotation;
/// Create a copy of Transform2D
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Transform2DCopyWith<Transform2D> get copyWith => _$Transform2DCopyWithImpl<Transform2D>(this as Transform2D, _$identity);

  /// Serializes this Transform2D to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transform2D&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.rotation, rotation) || other.rotation == rotation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y,width,height,scale,rotation);

@override
String toString() {
  return 'Transform2D(x: $x, y: $y, width: $width, height: $height, scale: $scale, rotation: $rotation)';
}


}

/// @nodoc
abstract mixin class $Transform2DCopyWith<$Res>  {
  factory $Transform2DCopyWith(Transform2D value, $Res Function(Transform2D) _then) = _$Transform2DCopyWithImpl;
@useResult
$Res call({
 double x, double y, double width, double height, double scale, double rotation
});




}
/// @nodoc
class _$Transform2DCopyWithImpl<$Res>
    implements $Transform2DCopyWith<$Res> {
  _$Transform2DCopyWithImpl(this._self, this._then);

  final Transform2D _self;
  final $Res Function(Transform2D) _then;

/// Create a copy of Transform2D
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,Object? width = null,Object? height = null,Object? scale = null,Object? rotation = null,}) {
  return _then(Transform2D(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Transform2D].
extension Transform2DPatterns on Transform2D {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transform2D value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transform2D() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transform2D value)  $default,){
final _that = this;
switch (_that) {
case _Transform2D():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transform2D value)?  $default,){
final _that = this;
switch (_that) {
case _Transform2D() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double y,  double width,  double height,  double scale,  double rotation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transform2D() when $default != null:
return $default(_that.x,_that.y,_that.width,_that.height,_that.scale,_that.rotation);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double y,  double width,  double height,  double scale,  double rotation)  $default,) {final _that = this;
switch (_that) {
case _Transform2D():
return $default(_that.x,_that.y,_that.width,_that.height,_that.scale,_that.rotation);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double y,  double width,  double height,  double scale,  double rotation)?  $default,) {final _that = this;
switch (_that) {
case _Transform2D() when $default != null:
return $default(_that.x,_that.y,_that.width,_that.height,_that.scale,_that.rotation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Transform2D implements Transform2D {
  const _Transform2D({required this.x, required this.y, this.width = 48, this.height = 64, this.scale = 1, this.rotation = 0});
  factory _Transform2D.fromJson(Map<String, dynamic> json) => _$Transform2DFromJson(json);

@override final  double x;
@override final  double y;
@override@JsonKey() final  double width;
@override@JsonKey() final  double height;
@override@JsonKey() final  double scale;
@override@JsonKey() final  double rotation;

/// Create a copy of Transform2D
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$Transform2DCopyWith<_Transform2D> get copyWith => __$Transform2DCopyWithImpl<_Transform2D>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$Transform2DToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transform2D&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.rotation, rotation) || other.rotation == rotation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y,width,height,scale,rotation);

@override
String toString() {
  return 'Transform2D(x: $x, y: $y, width: $width, height: $height, scale: $scale, rotation: $rotation)';
}


}

/// @nodoc
abstract mixin class _$Transform2DCopyWith<$Res> implements $Transform2DCopyWith<$Res> {
  factory _$Transform2DCopyWith(_Transform2D value, $Res Function(_Transform2D) _then) = __$Transform2DCopyWithImpl;
@override @useResult
$Res call({
 double x, double y, double width, double height, double scale, double rotation
});




}
/// @nodoc
class __$Transform2DCopyWithImpl<$Res>
    implements _$Transform2DCopyWith<$Res> {
  __$Transform2DCopyWithImpl(this._self, this._then);

  final _Transform2D _self;
  final $Res Function(_Transform2D) _then;

/// Create a copy of Transform2D
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,Object? width = null,Object? height = null,Object? scale = null,Object? rotation = null,}) {
  return _then(_Transform2D(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Character {

 String get id; String get name; List<AnimationClip> get animations; List<CharacterExpression> get expressions; CharacterMovementProfile get movement; Transform2D get defaultTransform; Direction get defaultFacing; String? get defaultExpressionId;
/// Create a copy of Character
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterCopyWith<Character> get copyWith => _$CharacterCopyWithImpl<Character>(this as Character, _$identity);

  /// Serializes this Character to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Character&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.animations, animations)&&const DeepCollectionEquality().equals(other.expressions, expressions)&&(identical(other.movement, movement) || other.movement == movement)&&(identical(other.defaultTransform, defaultTransform) || other.defaultTransform == defaultTransform)&&(identical(other.defaultFacing, defaultFacing) || other.defaultFacing == defaultFacing)&&(identical(other.defaultExpressionId, defaultExpressionId) || other.defaultExpressionId == defaultExpressionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(animations),const DeepCollectionEquality().hash(expressions),movement,defaultTransform,defaultFacing,defaultExpressionId);

@override
String toString() {
  return 'Character(id: $id, name: $name, animations: $animations, expressions: $expressions, movement: $movement, defaultTransform: $defaultTransform, defaultFacing: $defaultFacing, defaultExpressionId: $defaultExpressionId)';
}


}

/// @nodoc
abstract mixin class $CharacterCopyWith<$Res>  {
  factory $CharacterCopyWith(Character value, $Res Function(Character) _then) = _$CharacterCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<AnimationClip> animations, List<CharacterExpression> expressions, CharacterMovementProfile movement, Transform2D defaultTransform, Direction defaultFacing, String? defaultExpressionId
});


$CharacterMovementProfileCopyWith<$Res> get movement;$Transform2DCopyWith<$Res> get defaultTransform;

}
/// @nodoc
class _$CharacterCopyWithImpl<$Res>
    implements $CharacterCopyWith<$Res> {
  _$CharacterCopyWithImpl(this._self, this._then);

  final Character _self;
  final $Res Function(Character) _then;

/// Create a copy of Character
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? animations = null,Object? expressions = null,Object? movement = null,Object? defaultTransform = null,Object? defaultFacing = null,Object? defaultExpressionId = freezed,}) {
  return _then(Character(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,animations: null == animations ? _self.animations : animations // ignore: cast_nullable_to_non_nullable
as List<AnimationClip>,expressions: null == expressions ? _self.expressions : expressions // ignore: cast_nullable_to_non_nullable
as List<CharacterExpression>,movement: null == movement ? _self.movement : movement // ignore: cast_nullable_to_non_nullable
as CharacterMovementProfile,defaultTransform: null == defaultTransform ? _self.defaultTransform : defaultTransform // ignore: cast_nullable_to_non_nullable
as Transform2D,defaultFacing: null == defaultFacing ? _self.defaultFacing : defaultFacing // ignore: cast_nullable_to_non_nullable
as Direction,defaultExpressionId: freezed == defaultExpressionId ? _self.defaultExpressionId : defaultExpressionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Character
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CharacterMovementProfileCopyWith<$Res> get movement {
  
  return $CharacterMovementProfileCopyWith<$Res>(_self.movement, (value) {
    return _then(_self.copyWith(movement: value));
  });
}/// Create a copy of Character
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Transform2DCopyWith<$Res> get defaultTransform {
  
  return $Transform2DCopyWith<$Res>(_self.defaultTransform, (value) {
    return _then(_self.copyWith(defaultTransform: value));
  });
}
}


/// Adds pattern-matching-related methods to [Character].
extension CharacterPatterns on Character {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Character value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Character() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Character value)  $default,){
final _that = this;
switch (_that) {
case _Character():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Character value)?  $default,){
final _that = this;
switch (_that) {
case _Character() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<AnimationClip> animations,  List<CharacterExpression> expressions,  CharacterMovementProfile movement,  Transform2D defaultTransform,  Direction defaultFacing,  String? defaultExpressionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Character() when $default != null:
return $default(_that.id,_that.name,_that.animations,_that.expressions,_that.movement,_that.defaultTransform,_that.defaultFacing,_that.defaultExpressionId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<AnimationClip> animations,  List<CharacterExpression> expressions,  CharacterMovementProfile movement,  Transform2D defaultTransform,  Direction defaultFacing,  String? defaultExpressionId)  $default,) {final _that = this;
switch (_that) {
case _Character():
return $default(_that.id,_that.name,_that.animations,_that.expressions,_that.movement,_that.defaultTransform,_that.defaultFacing,_that.defaultExpressionId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<AnimationClip> animations,  List<CharacterExpression> expressions,  CharacterMovementProfile movement,  Transform2D defaultTransform,  Direction defaultFacing,  String? defaultExpressionId)?  $default,) {final _that = this;
switch (_that) {
case _Character() when $default != null:
return $default(_that.id,_that.name,_that.animations,_that.expressions,_that.movement,_that.defaultTransform,_that.defaultFacing,_that.defaultExpressionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Character implements Character {
  const _Character({required this.id, required this.name, required  List<AnimationClip> animations, required  List<CharacterExpression> expressions, required this.movement, this.defaultTransform = const Transform2D(x: 180, y: 180), this.defaultFacing = Direction.down, this.defaultExpressionId}): _animations = animations,_expressions = expressions;
  factory _Character.fromJson(Map<String, dynamic> json) => _$CharacterFromJson(json);

@override final  String id;
@override final  String name;
 final  List<AnimationClip> _animations;
@override List<AnimationClip> get animations {
  if (_animations is EqualUnmodifiableListView) return _animations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animations);
}

 final  List<CharacterExpression> _expressions;
@override List<CharacterExpression> get expressions {
  if (_expressions is EqualUnmodifiableListView) return _expressions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expressions);
}

@override final  CharacterMovementProfile movement;
@override@JsonKey() final  Transform2D defaultTransform;
@override@JsonKey() final  Direction defaultFacing;
@override final  String? defaultExpressionId;

/// Create a copy of Character
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CharacterCopyWith<_Character> get copyWith => __$CharacterCopyWithImpl<_Character>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CharacterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Character&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._animations, _animations)&&const DeepCollectionEquality().equals(other._expressions, _expressions)&&(identical(other.movement, movement) || other.movement == movement)&&(identical(other.defaultTransform, defaultTransform) || other.defaultTransform == defaultTransform)&&(identical(other.defaultFacing, defaultFacing) || other.defaultFacing == defaultFacing)&&(identical(other.defaultExpressionId, defaultExpressionId) || other.defaultExpressionId == defaultExpressionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_animations),const DeepCollectionEquality().hash(_expressions),movement,defaultTransform,defaultFacing,defaultExpressionId);

@override
String toString() {
  return 'Character(id: $id, name: $name, animations: $animations, expressions: $expressions, movement: $movement, defaultTransform: $defaultTransform, defaultFacing: $defaultFacing, defaultExpressionId: $defaultExpressionId)';
}


}

/// @nodoc
abstract mixin class _$CharacterCopyWith<$Res> implements $CharacterCopyWith<$Res> {
  factory _$CharacterCopyWith(_Character value, $Res Function(_Character) _then) = __$CharacterCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<AnimationClip> animations, List<CharacterExpression> expressions, CharacterMovementProfile movement, Transform2D defaultTransform, Direction defaultFacing, String? defaultExpressionId
});


@override $CharacterMovementProfileCopyWith<$Res> get movement;@override $Transform2DCopyWith<$Res> get defaultTransform;

}
/// @nodoc
class __$CharacterCopyWithImpl<$Res>
    implements _$CharacterCopyWith<$Res> {
  __$CharacterCopyWithImpl(this._self, this._then);

  final _Character _self;
  final $Res Function(_Character) _then;

/// Create a copy of Character
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? animations = null,Object? expressions = null,Object? movement = null,Object? defaultTransform = null,Object? defaultFacing = null,Object? defaultExpressionId = freezed,}) {
  return _then(_Character(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,animations: null == animations ? _self._animations : animations // ignore: cast_nullable_to_non_nullable
as List<AnimationClip>,expressions: null == expressions ? _self._expressions : expressions // ignore: cast_nullable_to_non_nullable
as List<CharacterExpression>,movement: null == movement ? _self.movement : movement // ignore: cast_nullable_to_non_nullable
as CharacterMovementProfile,defaultTransform: null == defaultTransform ? _self.defaultTransform : defaultTransform // ignore: cast_nullable_to_non_nullable
as Transform2D,defaultFacing: null == defaultFacing ? _self.defaultFacing : defaultFacing // ignore: cast_nullable_to_non_nullable
as Direction,defaultExpressionId: freezed == defaultExpressionId ? _self.defaultExpressionId : defaultExpressionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Character
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CharacterMovementProfileCopyWith<$Res> get movement {
  
  return $CharacterMovementProfileCopyWith<$Res>(_self.movement, (value) {
    return _then(_self.copyWith(movement: value));
  });
}/// Create a copy of Character
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Transform2DCopyWith<$Res> get defaultTransform {
  
  return $Transform2DCopyWith<$Res>(_self.defaultTransform, (value) {
    return _then(_self.copyWith(defaultTransform: value));
  });
}
}


/// @nodoc
mixin _$AnimationClip {

 String get id; String get name; String get assetId; Direction? get direction; double get framesPerSecond;
/// Create a copy of AnimationClip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimationClipCopyWith<AnimationClip> get copyWith => _$AnimationClipCopyWithImpl<AnimationClip>(this as AnimationClip, _$identity);

  /// Serializes this AnimationClip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimationClip&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.framesPerSecond, framesPerSecond) || other.framesPerSecond == framesPerSecond));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,assetId,direction,framesPerSecond);

@override
String toString() {
  return 'AnimationClip(id: $id, name: $name, assetId: $assetId, direction: $direction, framesPerSecond: $framesPerSecond)';
}


}

/// @nodoc
abstract mixin class $AnimationClipCopyWith<$Res>  {
  factory $AnimationClipCopyWith(AnimationClip value, $Res Function(AnimationClip) _then) = _$AnimationClipCopyWithImpl;
@useResult
$Res call({
 String id, String name, String assetId, Direction? direction, double framesPerSecond
});




}
/// @nodoc
class _$AnimationClipCopyWithImpl<$Res>
    implements $AnimationClipCopyWith<$Res> {
  _$AnimationClipCopyWithImpl(this._self, this._then);

  final AnimationClip _self;
  final $Res Function(AnimationClip) _then;

/// Create a copy of AnimationClip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? assetId = null,Object? direction = freezed,Object? framesPerSecond = null,}) {
  return _then(AnimationClip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction?,framesPerSecond: null == framesPerSecond ? _self.framesPerSecond : framesPerSecond // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimationClip].
extension AnimationClipPatterns on AnimationClip {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimationClip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimationClip() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimationClip value)  $default,){
final _that = this;
switch (_that) {
case _AnimationClip():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimationClip value)?  $default,){
final _that = this;
switch (_that) {
case _AnimationClip() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String assetId,  Direction? direction,  double framesPerSecond)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimationClip() when $default != null:
return $default(_that.id,_that.name,_that.assetId,_that.direction,_that.framesPerSecond);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String assetId,  Direction? direction,  double framesPerSecond)  $default,) {final _that = this;
switch (_that) {
case _AnimationClip():
return $default(_that.id,_that.name,_that.assetId,_that.direction,_that.framesPerSecond);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String assetId,  Direction? direction,  double framesPerSecond)?  $default,) {final _that = this;
switch (_that) {
case _AnimationClip() when $default != null:
return $default(_that.id,_that.name,_that.assetId,_that.direction,_that.framesPerSecond);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnimationClip implements AnimationClip {
  const _AnimationClip({required this.id, required this.name, required this.assetId, this.direction, this.framesPerSecond = 8});
  factory _AnimationClip.fromJson(Map<String, dynamic> json) => _$AnimationClipFromJson(json);

@override final  String id;
@override final  String name;
@override final  String assetId;
@override final  Direction? direction;
@override@JsonKey() final  double framesPerSecond;

/// Create a copy of AnimationClip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimationClipCopyWith<_AnimationClip> get copyWith => __$AnimationClipCopyWithImpl<_AnimationClip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnimationClipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimationClip&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.framesPerSecond, framesPerSecond) || other.framesPerSecond == framesPerSecond));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,assetId,direction,framesPerSecond);

@override
String toString() {
  return 'AnimationClip(id: $id, name: $name, assetId: $assetId, direction: $direction, framesPerSecond: $framesPerSecond)';
}


}

/// @nodoc
abstract mixin class _$AnimationClipCopyWith<$Res> implements $AnimationClipCopyWith<$Res> {
  factory _$AnimationClipCopyWith(_AnimationClip value, $Res Function(_AnimationClip) _then) = __$AnimationClipCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String assetId, Direction? direction, double framesPerSecond
});




}
/// @nodoc
class __$AnimationClipCopyWithImpl<$Res>
    implements _$AnimationClipCopyWith<$Res> {
  __$AnimationClipCopyWithImpl(this._self, this._then);

  final _AnimationClip _self;
  final $Res Function(_AnimationClip) _then;

/// Create a copy of AnimationClip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? assetId = null,Object? direction = freezed,Object? framesPerSecond = null,}) {
  return _then(_AnimationClip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction?,framesPerSecond: null == framesPerSecond ? _self.framesPerSecond : framesPerSecond // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$CharacterExpression {

 String get id; String get name; String? get assetId; Direction? get direction;
/// Create a copy of CharacterExpression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterExpressionCopyWith<CharacterExpression> get copyWith => _$CharacterExpressionCopyWithImpl<CharacterExpression>(this as CharacterExpression, _$identity);

  /// Serializes this CharacterExpression to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CharacterExpression&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.direction, direction) || other.direction == direction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,assetId,direction);

@override
String toString() {
  return 'CharacterExpression(id: $id, name: $name, assetId: $assetId, direction: $direction)';
}


}

/// @nodoc
abstract mixin class $CharacterExpressionCopyWith<$Res>  {
  factory $CharacterExpressionCopyWith(CharacterExpression value, $Res Function(CharacterExpression) _then) = _$CharacterExpressionCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? assetId, Direction? direction
});




}
/// @nodoc
class _$CharacterExpressionCopyWithImpl<$Res>
    implements $CharacterExpressionCopyWith<$Res> {
  _$CharacterExpressionCopyWithImpl(this._self, this._then);

  final CharacterExpression _self;
  final $Res Function(CharacterExpression) _then;

/// Create a copy of CharacterExpression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? assetId = freezed,Object? direction = freezed,}) {
  return _then(CharacterExpression(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,assetId: freezed == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction?,
  ));
}

}


/// Adds pattern-matching-related methods to [CharacterExpression].
extension CharacterExpressionPatterns on CharacterExpression {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CharacterExpression value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CharacterExpression() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CharacterExpression value)  $default,){
final _that = this;
switch (_that) {
case _CharacterExpression():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CharacterExpression value)?  $default,){
final _that = this;
switch (_that) {
case _CharacterExpression() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? assetId,  Direction? direction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CharacterExpression() when $default != null:
return $default(_that.id,_that.name,_that.assetId,_that.direction);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? assetId,  Direction? direction)  $default,) {final _that = this;
switch (_that) {
case _CharacterExpression():
return $default(_that.id,_that.name,_that.assetId,_that.direction);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? assetId,  Direction? direction)?  $default,) {final _that = this;
switch (_that) {
case _CharacterExpression() when $default != null:
return $default(_that.id,_that.name,_that.assetId,_that.direction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CharacterExpression implements CharacterExpression {
  const _CharacterExpression({required this.id, required this.name, this.assetId, this.direction});
  factory _CharacterExpression.fromJson(Map<String, dynamic> json) => _$CharacterExpressionFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? assetId;
@override final  Direction? direction;

/// Create a copy of CharacterExpression
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CharacterExpressionCopyWith<_CharacterExpression> get copyWith => __$CharacterExpressionCopyWithImpl<_CharacterExpression>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CharacterExpressionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CharacterExpression&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.direction, direction) || other.direction == direction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,assetId,direction);

@override
String toString() {
  return 'CharacterExpression(id: $id, name: $name, assetId: $assetId, direction: $direction)';
}


}

/// @nodoc
abstract mixin class _$CharacterExpressionCopyWith<$Res> implements $CharacterExpressionCopyWith<$Res> {
  factory _$CharacterExpressionCopyWith(_CharacterExpression value, $Res Function(_CharacterExpression) _then) = __$CharacterExpressionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? assetId, Direction? direction
});




}
/// @nodoc
class __$CharacterExpressionCopyWithImpl<$Res>
    implements _$CharacterExpressionCopyWith<$Res> {
  __$CharacterExpressionCopyWithImpl(this._self, this._then);

  final _CharacterExpression _self;
  final $Res Function(_CharacterExpression) _then;

/// Create a copy of CharacterExpression
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? assetId = freezed,Object? direction = freezed,}) {
  return _then(_CharacterExpression(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,assetId: freezed == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction?,
  ));
}


}


/// @nodoc
mixin _$CharacterMovementProfile {

 double get defaultSpeed; double get defaultShake;
/// Create a copy of CharacterMovementProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterMovementProfileCopyWith<CharacterMovementProfile> get copyWith => _$CharacterMovementProfileCopyWithImpl<CharacterMovementProfile>(this as CharacterMovementProfile, _$identity);

  /// Serializes this CharacterMovementProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CharacterMovementProfile&&(identical(other.defaultSpeed, defaultSpeed) || other.defaultSpeed == defaultSpeed)&&(identical(other.defaultShake, defaultShake) || other.defaultShake == defaultShake));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultSpeed,defaultShake);

@override
String toString() {
  return 'CharacterMovementProfile(defaultSpeed: $defaultSpeed, defaultShake: $defaultShake)';
}


}

/// @nodoc
abstract mixin class $CharacterMovementProfileCopyWith<$Res>  {
  factory $CharacterMovementProfileCopyWith(CharacterMovementProfile value, $Res Function(CharacterMovementProfile) _then) = _$CharacterMovementProfileCopyWithImpl;
@useResult
$Res call({
 double defaultSpeed, double defaultShake
});




}
/// @nodoc
class _$CharacterMovementProfileCopyWithImpl<$Res>
    implements $CharacterMovementProfileCopyWith<$Res> {
  _$CharacterMovementProfileCopyWithImpl(this._self, this._then);

  final CharacterMovementProfile _self;
  final $Res Function(CharacterMovementProfile) _then;

/// Create a copy of CharacterMovementProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultSpeed = null,Object? defaultShake = null,}) {
  return _then(CharacterMovementProfile(
defaultSpeed: null == defaultSpeed ? _self.defaultSpeed : defaultSpeed // ignore: cast_nullable_to_non_nullable
as double,defaultShake: null == defaultShake ? _self.defaultShake : defaultShake // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CharacterMovementProfile].
extension CharacterMovementProfilePatterns on CharacterMovementProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CharacterMovementProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CharacterMovementProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CharacterMovementProfile value)  $default,){
final _that = this;
switch (_that) {
case _CharacterMovementProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CharacterMovementProfile value)?  $default,){
final _that = this;
switch (_that) {
case _CharacterMovementProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double defaultSpeed,  double defaultShake)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CharacterMovementProfile() when $default != null:
return $default(_that.defaultSpeed,_that.defaultShake);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double defaultSpeed,  double defaultShake)  $default,) {final _that = this;
switch (_that) {
case _CharacterMovementProfile():
return $default(_that.defaultSpeed,_that.defaultShake);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double defaultSpeed,  double defaultShake)?  $default,) {final _that = this;
switch (_that) {
case _CharacterMovementProfile() when $default != null:
return $default(_that.defaultSpeed,_that.defaultShake);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CharacterMovementProfile implements CharacterMovementProfile {
  const _CharacterMovementProfile({this.defaultSpeed = 320, this.defaultShake = 16});
  factory _CharacterMovementProfile.fromJson(Map<String, dynamic> json) => _$CharacterMovementProfileFromJson(json);

@override@JsonKey() final  double defaultSpeed;
@override@JsonKey() final  double defaultShake;

/// Create a copy of CharacterMovementProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CharacterMovementProfileCopyWith<_CharacterMovementProfile> get copyWith => __$CharacterMovementProfileCopyWithImpl<_CharacterMovementProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CharacterMovementProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CharacterMovementProfile&&(identical(other.defaultSpeed, defaultSpeed) || other.defaultSpeed == defaultSpeed)&&(identical(other.defaultShake, defaultShake) || other.defaultShake == defaultShake));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultSpeed,defaultShake);

@override
String toString() {
  return 'CharacterMovementProfile(defaultSpeed: $defaultSpeed, defaultShake: $defaultShake)';
}


}

/// @nodoc
abstract mixin class _$CharacterMovementProfileCopyWith<$Res> implements $CharacterMovementProfileCopyWith<$Res> {
  factory _$CharacterMovementProfileCopyWith(_CharacterMovementProfile value, $Res Function(_CharacterMovementProfile) _then) = __$CharacterMovementProfileCopyWithImpl;
@override @useResult
$Res call({
 double defaultSpeed, double defaultShake
});




}
/// @nodoc
class __$CharacterMovementProfileCopyWithImpl<$Res>
    implements _$CharacterMovementProfileCopyWith<$Res> {
  __$CharacterMovementProfileCopyWithImpl(this._self, this._then);

  final _CharacterMovementProfile _self;
  final $Res Function(_CharacterMovementProfile) _then;

/// Create a copy of CharacterMovementProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultSpeed = null,Object? defaultShake = null,}) {
  return _then(_CharacterMovementProfile(
defaultSpeed: null == defaultSpeed ? _self.defaultSpeed : defaultSpeed // ignore: cast_nullable_to_non_nullable
as double,defaultShake: null == defaultShake ? _self.defaultShake : defaultShake // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$MovementPath {

 List<PathNode> get nodes; double get speed; double get shake;
/// Create a copy of MovementPath
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovementPathCopyWith<MovementPath> get copyWith => _$MovementPathCopyWithImpl<MovementPath>(this as MovementPath, _$identity);

  /// Serializes this MovementPath to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovementPath&&const DeepCollectionEquality().equals(other.nodes, nodes)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.shake, shake) || other.shake == shake));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(nodes),speed,shake);

@override
String toString() {
  return 'MovementPath(nodes: $nodes, speed: $speed, shake: $shake)';
}


}

/// @nodoc
abstract mixin class $MovementPathCopyWith<$Res>  {
  factory $MovementPathCopyWith(MovementPath value, $Res Function(MovementPath) _then) = _$MovementPathCopyWithImpl;
@useResult
$Res call({
 List<PathNode> nodes, double speed, double shake
});




}
/// @nodoc
class _$MovementPathCopyWithImpl<$Res>
    implements $MovementPathCopyWith<$Res> {
  _$MovementPathCopyWithImpl(this._self, this._then);

  final MovementPath _self;
  final $Res Function(MovementPath) _then;

/// Create a copy of MovementPath
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nodes = null,Object? speed = null,Object? shake = null,}) {
  return _then(MovementPath(
nodes: null == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<PathNode>,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,shake: null == shake ? _self.shake : shake // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MovementPath].
extension MovementPathPatterns on MovementPath {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovementPath value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovementPath() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovementPath value)  $default,){
final _that = this;
switch (_that) {
case _MovementPath():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovementPath value)?  $default,){
final _that = this;
switch (_that) {
case _MovementPath() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PathNode> nodes,  double speed,  double shake)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovementPath() when $default != null:
return $default(_that.nodes,_that.speed,_that.shake);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PathNode> nodes,  double speed,  double shake)  $default,) {final _that = this;
switch (_that) {
case _MovementPath():
return $default(_that.nodes,_that.speed,_that.shake);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PathNode> nodes,  double speed,  double shake)?  $default,) {final _that = this;
switch (_that) {
case _MovementPath() when $default != null:
return $default(_that.nodes,_that.speed,_that.shake);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MovementPath implements MovementPath {
  const _MovementPath({required  List<PathNode> nodes, this.speed = 320, this.shake = 0}): _nodes = nodes;
  factory _MovementPath.fromJson(Map<String, dynamic> json) => _$MovementPathFromJson(json);

 final  List<PathNode> _nodes;
@override List<PathNode> get nodes {
  if (_nodes is EqualUnmodifiableListView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nodes);
}

@override@JsonKey() final  double speed;
@override@JsonKey() final  double shake;

/// Create a copy of MovementPath
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovementPathCopyWith<_MovementPath> get copyWith => __$MovementPathCopyWithImpl<_MovementPath>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovementPathToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovementPath&&const DeepCollectionEquality().equals(other._nodes, _nodes)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.shake, shake) || other.shake == shake));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_nodes),speed,shake);

@override
String toString() {
  return 'MovementPath(nodes: $nodes, speed: $speed, shake: $shake)';
}


}

/// @nodoc
abstract mixin class _$MovementPathCopyWith<$Res> implements $MovementPathCopyWith<$Res> {
  factory _$MovementPathCopyWith(_MovementPath value, $Res Function(_MovementPath) _then) = __$MovementPathCopyWithImpl;
@override @useResult
$Res call({
 List<PathNode> nodes, double speed, double shake
});




}
/// @nodoc
class __$MovementPathCopyWithImpl<$Res>
    implements _$MovementPathCopyWith<$Res> {
  __$MovementPathCopyWithImpl(this._self, this._then);

  final _MovementPath _self;
  final $Res Function(_MovementPath) _then;

/// Create a copy of MovementPath
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nodes = null,Object? speed = null,Object? shake = null,}) {
  return _then(_MovementPath(
nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<PathNode>,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,shake: null == shake ? _self.shake : shake // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PathNode {

 String get id; String get name; double get x; double get y; double? get waitSeconds; String? get triggerId;
/// Create a copy of PathNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PathNodeCopyWith<PathNode> get copyWith => _$PathNodeCopyWithImpl<PathNode>(this as PathNode, _$identity);

  /// Serializes this PathNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PathNode&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.waitSeconds, waitSeconds) || other.waitSeconds == waitSeconds)&&(identical(other.triggerId, triggerId) || other.triggerId == triggerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,x,y,waitSeconds,triggerId);

@override
String toString() {
  return 'PathNode(id: $id, name: $name, x: $x, y: $y, waitSeconds: $waitSeconds, triggerId: $triggerId)';
}


}

/// @nodoc
abstract mixin class $PathNodeCopyWith<$Res>  {
  factory $PathNodeCopyWith(PathNode value, $Res Function(PathNode) _then) = _$PathNodeCopyWithImpl;
@useResult
$Res call({
 String id, String name, double x, double y, double? waitSeconds, String? triggerId
});




}
/// @nodoc
class _$PathNodeCopyWithImpl<$Res>
    implements $PathNodeCopyWith<$Res> {
  _$PathNodeCopyWithImpl(this._self, this._then);

  final PathNode _self;
  final $Res Function(PathNode) _then;

/// Create a copy of PathNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? x = null,Object? y = null,Object? waitSeconds = freezed,Object? triggerId = freezed,}) {
  return _then(PathNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,waitSeconds: freezed == waitSeconds ? _self.waitSeconds : waitSeconds // ignore: cast_nullable_to_non_nullable
as double?,triggerId: freezed == triggerId ? _self.triggerId : triggerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PathNode].
extension PathNodePatterns on PathNode {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PathNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PathNode() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PathNode value)  $default,){
final _that = this;
switch (_that) {
case _PathNode():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PathNode value)?  $default,){
final _that = this;
switch (_that) {
case _PathNode() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double x,  double y,  double? waitSeconds,  String? triggerId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PathNode() when $default != null:
return $default(_that.id,_that.name,_that.x,_that.y,_that.waitSeconds,_that.triggerId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double x,  double y,  double? waitSeconds,  String? triggerId)  $default,) {final _that = this;
switch (_that) {
case _PathNode():
return $default(_that.id,_that.name,_that.x,_that.y,_that.waitSeconds,_that.triggerId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double x,  double y,  double? waitSeconds,  String? triggerId)?  $default,) {final _that = this;
switch (_that) {
case _PathNode() when $default != null:
return $default(_that.id,_that.name,_that.x,_that.y,_that.waitSeconds,_that.triggerId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PathNode implements PathNode {
  const _PathNode({required this.id, this.name = 'Node', required this.x, required this.y, this.waitSeconds, this.triggerId});
  factory _PathNode.fromJson(Map<String, dynamic> json) => _$PathNodeFromJson(json);

@override final  String id;
@override@JsonKey() final  String name;
@override final  double x;
@override final  double y;
@override final  double? waitSeconds;
@override final  String? triggerId;

/// Create a copy of PathNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PathNodeCopyWith<_PathNode> get copyWith => __$PathNodeCopyWithImpl<_PathNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PathNodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PathNode&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.waitSeconds, waitSeconds) || other.waitSeconds == waitSeconds)&&(identical(other.triggerId, triggerId) || other.triggerId == triggerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,x,y,waitSeconds,triggerId);

@override
String toString() {
  return 'PathNode(id: $id, name: $name, x: $x, y: $y, waitSeconds: $waitSeconds, triggerId: $triggerId)';
}


}

/// @nodoc
abstract mixin class _$PathNodeCopyWith<$Res> implements $PathNodeCopyWith<$Res> {
  factory _$PathNodeCopyWith(_PathNode value, $Res Function(_PathNode) _then) = __$PathNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double x, double y, double? waitSeconds, String? triggerId
});




}
/// @nodoc
class __$PathNodeCopyWithImpl<$Res>
    implements _$PathNodeCopyWith<$Res> {
  __$PathNodeCopyWithImpl(this._self, this._then);

  final _PathNode _self;
  final $Res Function(_PathNode) _then;

/// Create a copy of PathNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? x = null,Object? y = null,Object? waitSeconds = freezed,Object? triggerId = freezed,}) {
  return _then(_PathNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,waitSeconds: freezed == waitSeconds ? _self.waitSeconds : waitSeconds // ignore: cast_nullable_to_non_nullable
as double?,triggerId: freezed == triggerId ? _self.triggerId : triggerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ActivityProfile {

 String get zoneId; int get level; double get idleBias; double get interestBias;
/// Create a copy of ActivityProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityProfileCopyWith<ActivityProfile> get copyWith => _$ActivityProfileCopyWithImpl<ActivityProfile>(this as ActivityProfile, _$identity);

  /// Serializes this ActivityProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityProfile&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.level, level) || other.level == level)&&(identical(other.idleBias, idleBias) || other.idleBias == idleBias)&&(identical(other.interestBias, interestBias) || other.interestBias == interestBias));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,zoneId,level,idleBias,interestBias);

@override
String toString() {
  return 'ActivityProfile(zoneId: $zoneId, level: $level, idleBias: $idleBias, interestBias: $interestBias)';
}


}

/// @nodoc
abstract mixin class $ActivityProfileCopyWith<$Res>  {
  factory $ActivityProfileCopyWith(ActivityProfile value, $Res Function(ActivityProfile) _then) = _$ActivityProfileCopyWithImpl;
@useResult
$Res call({
 String zoneId, int level, double idleBias, double interestBias
});




}
/// @nodoc
class _$ActivityProfileCopyWithImpl<$Res>
    implements $ActivityProfileCopyWith<$Res> {
  _$ActivityProfileCopyWithImpl(this._self, this._then);

  final ActivityProfile _self;
  final $Res Function(ActivityProfile) _then;

/// Create a copy of ActivityProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? zoneId = null,Object? level = null,Object? idleBias = null,Object? interestBias = null,}) {
  return _then(ActivityProfile(
zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,idleBias: null == idleBias ? _self.idleBias : idleBias // ignore: cast_nullable_to_non_nullable
as double,interestBias: null == interestBias ? _self.interestBias : interestBias // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityProfile].
extension ActivityProfilePatterns on ActivityProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityProfile value)  $default,){
final _that = this;
switch (_that) {
case _ActivityProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String zoneId,  int level,  double idleBias,  double interestBias)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityProfile() when $default != null:
return $default(_that.zoneId,_that.level,_that.idleBias,_that.interestBias);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String zoneId,  int level,  double idleBias,  double interestBias)  $default,) {final _that = this;
switch (_that) {
case _ActivityProfile():
return $default(_that.zoneId,_that.level,_that.idleBias,_that.interestBias);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String zoneId,  int level,  double idleBias,  double interestBias)?  $default,) {final _that = this;
switch (_that) {
case _ActivityProfile() when $default != null:
return $default(_that.zoneId,_that.level,_that.idleBias,_that.interestBias);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityProfile implements ActivityProfile {
  const _ActivityProfile({required this.zoneId, this.level = 50, this.idleBias = 0.5, this.interestBias = 0.5});
  factory _ActivityProfile.fromJson(Map<String, dynamic> json) => _$ActivityProfileFromJson(json);

@override final  String zoneId;
@override@JsonKey() final  int level;
@override@JsonKey() final  double idleBias;
@override@JsonKey() final  double interestBias;

/// Create a copy of ActivityProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityProfileCopyWith<_ActivityProfile> get copyWith => __$ActivityProfileCopyWithImpl<_ActivityProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityProfile&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.level, level) || other.level == level)&&(identical(other.idleBias, idleBias) || other.idleBias == idleBias)&&(identical(other.interestBias, interestBias) || other.interestBias == interestBias));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,zoneId,level,idleBias,interestBias);

@override
String toString() {
  return 'ActivityProfile(zoneId: $zoneId, level: $level, idleBias: $idleBias, interestBias: $interestBias)';
}


}

/// @nodoc
abstract mixin class _$ActivityProfileCopyWith<$Res> implements $ActivityProfileCopyWith<$Res> {
  factory _$ActivityProfileCopyWith(_ActivityProfile value, $Res Function(_ActivityProfile) _then) = __$ActivityProfileCopyWithImpl;
@override @useResult
$Res call({
 String zoneId, int level, double idleBias, double interestBias
});




}
/// @nodoc
class __$ActivityProfileCopyWithImpl<$Res>
    implements _$ActivityProfileCopyWith<$Res> {
  __$ActivityProfileCopyWithImpl(this._self, this._then);

  final _ActivityProfile _self;
  final $Res Function(_ActivityProfile) _then;

/// Create a copy of ActivityProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? zoneId = null,Object? level = null,Object? idleBias = null,Object? interestBias = null,}) {
  return _then(_ActivityProfile(
zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,idleBias: null == idleBias ? _self.idleBias : idleBias // ignore: cast_nullable_to_non_nullable
as double,interestBias: null == interestBias ? _self.interestBias : interestBias // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$InterestPoint {

 String get id; String get name; String get kind; double get x; double get y;
/// Create a copy of InterestPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterestPointCopyWith<InterestPoint> get copyWith => _$InterestPointCopyWithImpl<InterestPoint>(this as InterestPoint, _$identity);

  /// Serializes this InterestPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InterestPoint&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,kind,x,y);

@override
String toString() {
  return 'InterestPoint(id: $id, name: $name, kind: $kind, x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class $InterestPointCopyWith<$Res>  {
  factory $InterestPointCopyWith(InterestPoint value, $Res Function(InterestPoint) _then) = _$InterestPointCopyWithImpl;
@useResult
$Res call({
 String id, String name, String kind, double x, double y
});




}
/// @nodoc
class _$InterestPointCopyWithImpl<$Res>
    implements $InterestPointCopyWith<$Res> {
  _$InterestPointCopyWithImpl(this._self, this._then);

  final InterestPoint _self;
  final $Res Function(InterestPoint) _then;

/// Create a copy of InterestPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? x = null,Object? y = null,}) {
  return _then(InterestPoint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [InterestPoint].
extension InterestPointPatterns on InterestPoint {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InterestPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InterestPoint() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InterestPoint value)  $default,){
final _that = this;
switch (_that) {
case _InterestPoint():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InterestPoint value)?  $default,){
final _that = this;
switch (_that) {
case _InterestPoint() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String kind,  double x,  double y)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InterestPoint() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.x,_that.y);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String kind,  double x,  double y)  $default,) {final _that = this;
switch (_that) {
case _InterestPoint():
return $default(_that.id,_that.name,_that.kind,_that.x,_that.y);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String kind,  double x,  double y)?  $default,) {final _that = this;
switch (_that) {
case _InterestPoint() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.x,_that.y);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InterestPoint implements InterestPoint {
  const _InterestPoint({required this.id, required this.name, required this.kind, required this.x, required this.y});
  factory _InterestPoint.fromJson(Map<String, dynamic> json) => _$InterestPointFromJson(json);

@override final  String id;
@override final  String name;
@override final  String kind;
@override final  double x;
@override final  double y;

/// Create a copy of InterestPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterestPointCopyWith<_InterestPoint> get copyWith => __$InterestPointCopyWithImpl<_InterestPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InterestPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InterestPoint&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,kind,x,y);

@override
String toString() {
  return 'InterestPoint(id: $id, name: $name, kind: $kind, x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class _$InterestPointCopyWith<$Res> implements $InterestPointCopyWith<$Res> {
  factory _$InterestPointCopyWith(_InterestPoint value, $Res Function(_InterestPoint) _then) = __$InterestPointCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String kind, double x, double y
});




}
/// @nodoc
class __$InterestPointCopyWithImpl<$Res>
    implements _$InterestPointCopyWith<$Res> {
  __$InterestPointCopyWithImpl(this._self, this._then);

  final _InterestPoint _self;
  final $Res Function(_InterestPoint) _then;

/// Create a copy of InterestPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? x = null,Object? y = null,}) {
  return _then(_InterestPoint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

Trigger _$TriggerFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'area':
          return AreaTrigger.fromJson(
            json
          );
                case 'object':
          return ObjectTrigger.fromJson(
            json
          );
                case 'auto':
          return AutoTrigger.fromJson(
            json
          );
                case 'moveComplete':
          return MoveCompleteTrigger.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'Trigger',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$Trigger {

 String get id; String get name; String get eventChainId; String? get linkedTriggerId;
/// Create a copy of Trigger
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TriggerCopyWith<Trigger> get copyWith => _$TriggerCopyWithImpl<Trigger>(this as Trigger, _$identity);

  /// Serializes this Trigger to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trigger&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.eventChainId, eventChainId) || other.eventChainId == eventChainId)&&(identical(other.linkedTriggerId, linkedTriggerId) || other.linkedTriggerId == linkedTriggerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,eventChainId,linkedTriggerId);

@override
String toString() {
  return 'Trigger(id: $id, name: $name, eventChainId: $eventChainId, linkedTriggerId: $linkedTriggerId)';
}


}

/// @nodoc
abstract mixin class $TriggerCopyWith<$Res>  {
  factory $TriggerCopyWith(Trigger value, $Res Function(Trigger) _then) = _$TriggerCopyWithImpl;
@useResult
$Res call({
 String id, String name, String eventChainId, String? linkedTriggerId
});




}
/// @nodoc
class _$TriggerCopyWithImpl<$Res>
    implements $TriggerCopyWith<$Res> {
  _$TriggerCopyWithImpl(this._self, this._then);

  final Trigger _self;
  final $Res Function(Trigger) _then;

/// Create a copy of Trigger
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? eventChainId = null,Object? linkedTriggerId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,eventChainId: null == eventChainId ? _self.eventChainId : eventChainId // ignore: cast_nullable_to_non_nullable
as String,linkedTriggerId: freezed == linkedTriggerId ? _self.linkedTriggerId : linkedTriggerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Trigger].
extension TriggerPatterns on Trigger {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AreaTrigger value)?  area,TResult Function( ObjectTrigger value)?  object,TResult Function( AutoTrigger value)?  auto,TResult Function( MoveCompleteTrigger value)?  moveComplete,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AreaTrigger() when area != null:
return area(_that);case ObjectTrigger() when object != null:
return object(_that);case AutoTrigger() when auto != null:
return auto(_that);case MoveCompleteTrigger() when moveComplete != null:
return moveComplete(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AreaTrigger value)  area,required TResult Function( ObjectTrigger value)  object,required TResult Function( AutoTrigger value)  auto,required TResult Function( MoveCompleteTrigger value)  moveComplete,}){
final _that = this;
switch (_that) {
case AreaTrigger():
return area(_that);case ObjectTrigger():
return object(_that);case AutoTrigger():
return auto(_that);case MoveCompleteTrigger():
return moveComplete(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AreaTrigger value)?  area,TResult? Function( ObjectTrigger value)?  object,TResult? Function( AutoTrigger value)?  auto,TResult? Function( MoveCompleteTrigger value)?  moveComplete,}){
final _that = this;
switch (_that) {
case AreaTrigger() when area != null:
return area(_that);case ObjectTrigger() when object != null:
return object(_that);case AutoTrigger() when auto != null:
return auto(_that);case MoveCompleteTrigger() when moveComplete != null:
return moveComplete(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String name,  String eventChainId,  String? linkedTriggerId)?  area,TResult Function( String id,  String name,  String objectId,  String eventChainId,  String? linkedTriggerId)?  object,TResult Function( String id,  String name,  String eventChainId,  String? linkedTriggerId)?  auto,TResult Function( String id,  String name,  String targetObjectId,  String eventChainId,  String? linkedTriggerId)?  moveComplete,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AreaTrigger() when area != null:
return area(_that.id,_that.name,_that.eventChainId,_that.linkedTriggerId);case ObjectTrigger() when object != null:
return object(_that.id,_that.name,_that.objectId,_that.eventChainId,_that.linkedTriggerId);case AutoTrigger() when auto != null:
return auto(_that.id,_that.name,_that.eventChainId,_that.linkedTriggerId);case MoveCompleteTrigger() when moveComplete != null:
return moveComplete(_that.id,_that.name,_that.targetObjectId,_that.eventChainId,_that.linkedTriggerId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String name,  String eventChainId,  String? linkedTriggerId)  area,required TResult Function( String id,  String name,  String objectId,  String eventChainId,  String? linkedTriggerId)  object,required TResult Function( String id,  String name,  String eventChainId,  String? linkedTriggerId)  auto,required TResult Function( String id,  String name,  String targetObjectId,  String eventChainId,  String? linkedTriggerId)  moveComplete,}) {final _that = this;
switch (_that) {
case AreaTrigger():
return area(_that.id,_that.name,_that.eventChainId,_that.linkedTriggerId);case ObjectTrigger():
return object(_that.id,_that.name,_that.objectId,_that.eventChainId,_that.linkedTriggerId);case AutoTrigger():
return auto(_that.id,_that.name,_that.eventChainId,_that.linkedTriggerId);case MoveCompleteTrigger():
return moveComplete(_that.id,_that.name,_that.targetObjectId,_that.eventChainId,_that.linkedTriggerId);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String name,  String eventChainId,  String? linkedTriggerId)?  area,TResult? Function( String id,  String name,  String objectId,  String eventChainId,  String? linkedTriggerId)?  object,TResult? Function( String id,  String name,  String eventChainId,  String? linkedTriggerId)?  auto,TResult? Function( String id,  String name,  String targetObjectId,  String eventChainId,  String? linkedTriggerId)?  moveComplete,}) {final _that = this;
switch (_that) {
case AreaTrigger() when area != null:
return area(_that.id,_that.name,_that.eventChainId,_that.linkedTriggerId);case ObjectTrigger() when object != null:
return object(_that.id,_that.name,_that.objectId,_that.eventChainId,_that.linkedTriggerId);case AutoTrigger() when auto != null:
return auto(_that.id,_that.name,_that.eventChainId,_that.linkedTriggerId);case MoveCompleteTrigger() when moveComplete != null:
return moveComplete(_that.id,_that.name,_that.targetObjectId,_that.eventChainId,_that.linkedTriggerId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class AreaTrigger implements Trigger {
  const AreaTrigger({required this.id, required this.name, required this.eventChainId, this.linkedTriggerId,  String? $type}): $type = $type ?? 'area';
  factory AreaTrigger.fromJson(Map<String, dynamic> json) => _$AreaTriggerFromJson(json);

@override final  String id;
@override final  String name;
@override final  String eventChainId;
@override final  String? linkedTriggerId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of Trigger
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AreaTriggerCopyWith<AreaTrigger> get copyWith => _$AreaTriggerCopyWithImpl<AreaTrigger>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AreaTriggerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AreaTrigger&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.eventChainId, eventChainId) || other.eventChainId == eventChainId)&&(identical(other.linkedTriggerId, linkedTriggerId) || other.linkedTriggerId == linkedTriggerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,eventChainId,linkedTriggerId);

@override
String toString() {
  return 'Trigger.area(id: $id, name: $name, eventChainId: $eventChainId, linkedTriggerId: $linkedTriggerId)';
}


}

/// @nodoc
abstract mixin class $AreaTriggerCopyWith<$Res> implements $TriggerCopyWith<$Res> {
  factory $AreaTriggerCopyWith(AreaTrigger value, $Res Function(AreaTrigger) _then) = _$AreaTriggerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String eventChainId, String? linkedTriggerId
});




}
/// @nodoc
class _$AreaTriggerCopyWithImpl<$Res>
    implements $AreaTriggerCopyWith<$Res> {
  _$AreaTriggerCopyWithImpl(this._self, this._then);

  final AreaTrigger _self;
  final $Res Function(AreaTrigger) _then;

/// Create a copy of Trigger
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? eventChainId = null,Object? linkedTriggerId = freezed,}) {
  return _then(AreaTrigger(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,eventChainId: null == eventChainId ? _self.eventChainId : eventChainId // ignore: cast_nullable_to_non_nullable
as String,linkedTriggerId: freezed == linkedTriggerId ? _self.linkedTriggerId : linkedTriggerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ObjectTrigger implements Trigger {
  const ObjectTrigger({required this.id, required this.name, required this.objectId, required this.eventChainId, this.linkedTriggerId,  String? $type}): $type = $type ?? 'object';
  factory ObjectTrigger.fromJson(Map<String, dynamic> json) => _$ObjectTriggerFromJson(json);

@override final  String id;
@override final  String name;
 final  String objectId;
@override final  String eventChainId;
@override final  String? linkedTriggerId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of Trigger
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ObjectTriggerCopyWith<ObjectTrigger> get copyWith => _$ObjectTriggerCopyWithImpl<ObjectTrigger>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ObjectTriggerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ObjectTrigger&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.objectId, objectId) || other.objectId == objectId)&&(identical(other.eventChainId, eventChainId) || other.eventChainId == eventChainId)&&(identical(other.linkedTriggerId, linkedTriggerId) || other.linkedTriggerId == linkedTriggerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,objectId,eventChainId,linkedTriggerId);

@override
String toString() {
  return 'Trigger.object(id: $id, name: $name, objectId: $objectId, eventChainId: $eventChainId, linkedTriggerId: $linkedTriggerId)';
}


}

/// @nodoc
abstract mixin class $ObjectTriggerCopyWith<$Res> implements $TriggerCopyWith<$Res> {
  factory $ObjectTriggerCopyWith(ObjectTrigger value, $Res Function(ObjectTrigger) _then) = _$ObjectTriggerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String objectId, String eventChainId, String? linkedTriggerId
});




}
/// @nodoc
class _$ObjectTriggerCopyWithImpl<$Res>
    implements $ObjectTriggerCopyWith<$Res> {
  _$ObjectTriggerCopyWithImpl(this._self, this._then);

  final ObjectTrigger _self;
  final $Res Function(ObjectTrigger) _then;

/// Create a copy of Trigger
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? objectId = null,Object? eventChainId = null,Object? linkedTriggerId = freezed,}) {
  return _then(ObjectTrigger(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,objectId: null == objectId ? _self.objectId : objectId // ignore: cast_nullable_to_non_nullable
as String,eventChainId: null == eventChainId ? _self.eventChainId : eventChainId // ignore: cast_nullable_to_non_nullable
as String,linkedTriggerId: freezed == linkedTriggerId ? _self.linkedTriggerId : linkedTriggerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AutoTrigger implements Trigger {
  const AutoTrigger({required this.id, required this.name, required this.eventChainId, this.linkedTriggerId,  String? $type}): $type = $type ?? 'auto';
  factory AutoTrigger.fromJson(Map<String, dynamic> json) => _$AutoTriggerFromJson(json);

@override final  String id;
@override final  String name;
@override final  String eventChainId;
@override final  String? linkedTriggerId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of Trigger
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoTriggerCopyWith<AutoTrigger> get copyWith => _$AutoTriggerCopyWithImpl<AutoTrigger>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AutoTriggerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoTrigger&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.eventChainId, eventChainId) || other.eventChainId == eventChainId)&&(identical(other.linkedTriggerId, linkedTriggerId) || other.linkedTriggerId == linkedTriggerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,eventChainId,linkedTriggerId);

@override
String toString() {
  return 'Trigger.auto(id: $id, name: $name, eventChainId: $eventChainId, linkedTriggerId: $linkedTriggerId)';
}


}

/// @nodoc
abstract mixin class $AutoTriggerCopyWith<$Res> implements $TriggerCopyWith<$Res> {
  factory $AutoTriggerCopyWith(AutoTrigger value, $Res Function(AutoTrigger) _then) = _$AutoTriggerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String eventChainId, String? linkedTriggerId
});




}
/// @nodoc
class _$AutoTriggerCopyWithImpl<$Res>
    implements $AutoTriggerCopyWith<$Res> {
  _$AutoTriggerCopyWithImpl(this._self, this._then);

  final AutoTrigger _self;
  final $Res Function(AutoTrigger) _then;

/// Create a copy of Trigger
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? eventChainId = null,Object? linkedTriggerId = freezed,}) {
  return _then(AutoTrigger(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,eventChainId: null == eventChainId ? _self.eventChainId : eventChainId // ignore: cast_nullable_to_non_nullable
as String,linkedTriggerId: freezed == linkedTriggerId ? _self.linkedTriggerId : linkedTriggerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class MoveCompleteTrigger implements Trigger {
  const MoveCompleteTrigger({required this.id, required this.name, required this.targetObjectId, required this.eventChainId, this.linkedTriggerId,  String? $type}): $type = $type ?? 'moveComplete';
  factory MoveCompleteTrigger.fromJson(Map<String, dynamic> json) => _$MoveCompleteTriggerFromJson(json);

@override final  String id;
@override final  String name;
 final  String targetObjectId;
@override final  String eventChainId;
@override final  String? linkedTriggerId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of Trigger
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveCompleteTriggerCopyWith<MoveCompleteTrigger> get copyWith => _$MoveCompleteTriggerCopyWithImpl<MoveCompleteTrigger>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveCompleteTriggerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveCompleteTrigger&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetObjectId, targetObjectId) || other.targetObjectId == targetObjectId)&&(identical(other.eventChainId, eventChainId) || other.eventChainId == eventChainId)&&(identical(other.linkedTriggerId, linkedTriggerId) || other.linkedTriggerId == linkedTriggerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,targetObjectId,eventChainId,linkedTriggerId);

@override
String toString() {
  return 'Trigger.moveComplete(id: $id, name: $name, targetObjectId: $targetObjectId, eventChainId: $eventChainId, linkedTriggerId: $linkedTriggerId)';
}


}

/// @nodoc
abstract mixin class $MoveCompleteTriggerCopyWith<$Res> implements $TriggerCopyWith<$Res> {
  factory $MoveCompleteTriggerCopyWith(MoveCompleteTrigger value, $Res Function(MoveCompleteTrigger) _then) = _$MoveCompleteTriggerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String targetObjectId, String eventChainId, String? linkedTriggerId
});




}
/// @nodoc
class _$MoveCompleteTriggerCopyWithImpl<$Res>
    implements $MoveCompleteTriggerCopyWith<$Res> {
  _$MoveCompleteTriggerCopyWithImpl(this._self, this._then);

  final MoveCompleteTrigger _self;
  final $Res Function(MoveCompleteTrigger) _then;

/// Create a copy of Trigger
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? targetObjectId = null,Object? eventChainId = null,Object? linkedTriggerId = freezed,}) {
  return _then(MoveCompleteTrigger(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetObjectId: null == targetObjectId ? _self.targetObjectId : targetObjectId // ignore: cast_nullable_to_non_nullable
as String,eventChainId: null == eventChainId ? _self.eventChainId : eventChainId // ignore: cast_nullable_to_non_nullable
as String,linkedTriggerId: freezed == linkedTriggerId ? _self.linkedTriggerId : linkedTriggerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EventChain {

 String get id; String get name; EventChainTriggerMode get triggerMode; List<StudioEvent> get events;
/// Create a copy of EventChain
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventChainCopyWith<EventChain> get copyWith => _$EventChainCopyWithImpl<EventChain>(this as EventChain, _$identity);

  /// Serializes this EventChain to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventChain&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.triggerMode, triggerMode) || other.triggerMode == triggerMode)&&const DeepCollectionEquality().equals(other.events, events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,triggerMode,const DeepCollectionEquality().hash(events));

@override
String toString() {
  return 'EventChain(id: $id, name: $name, triggerMode: $triggerMode, events: $events)';
}


}

/// @nodoc
abstract mixin class $EventChainCopyWith<$Res>  {
  factory $EventChainCopyWith(EventChain value, $Res Function(EventChain) _then) = _$EventChainCopyWithImpl;
@useResult
$Res call({
 String id, String name, EventChainTriggerMode triggerMode, List<StudioEvent> events
});




}
/// @nodoc
class _$EventChainCopyWithImpl<$Res>
    implements $EventChainCopyWith<$Res> {
  _$EventChainCopyWithImpl(this._self, this._then);

  final EventChain _self;
  final $Res Function(EventChain) _then;

/// Create a copy of EventChain
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? triggerMode = null,Object? events = null,}) {
  return _then(EventChain(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,triggerMode: null == triggerMode ? _self.triggerMode : triggerMode // ignore: cast_nullable_to_non_nullable
as EventChainTriggerMode,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<StudioEvent>,
  ));
}

}


/// Adds pattern-matching-related methods to [EventChain].
extension EventChainPatterns on EventChain {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventChain value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventChain() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventChain value)  $default,){
final _that = this;
switch (_that) {
case _EventChain():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventChain value)?  $default,){
final _that = this;
switch (_that) {
case _EventChain() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  EventChainTriggerMode triggerMode,  List<StudioEvent> events)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventChain() when $default != null:
return $default(_that.id,_that.name,_that.triggerMode,_that.events);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  EventChainTriggerMode triggerMode,  List<StudioEvent> events)  $default,) {final _that = this;
switch (_that) {
case _EventChain():
return $default(_that.id,_that.name,_that.triggerMode,_that.events);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  EventChainTriggerMode triggerMode,  List<StudioEvent> events)?  $default,) {final _that = this;
switch (_that) {
case _EventChain() when $default != null:
return $default(_that.id,_that.name,_that.triggerMode,_that.events);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventChain implements EventChain {
  const _EventChain({required this.id, required this.name, this.triggerMode = EventChainTriggerMode.always, required  List<StudioEvent> events}): _events = events;
  factory _EventChain.fromJson(Map<String, dynamic> json) => _$EventChainFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  EventChainTriggerMode triggerMode;
 final  List<StudioEvent> _events;
@override List<StudioEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}


/// Create a copy of EventChain
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventChainCopyWith<_EventChain> get copyWith => __$EventChainCopyWithImpl<_EventChain>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventChainToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventChain&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.triggerMode, triggerMode) || other.triggerMode == triggerMode)&&const DeepCollectionEquality().equals(other._events, _events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,triggerMode,const DeepCollectionEquality().hash(_events));

@override
String toString() {
  return 'EventChain(id: $id, name: $name, triggerMode: $triggerMode, events: $events)';
}


}

/// @nodoc
abstract mixin class _$EventChainCopyWith<$Res> implements $EventChainCopyWith<$Res> {
  factory _$EventChainCopyWith(_EventChain value, $Res Function(_EventChain) _then) = __$EventChainCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, EventChainTriggerMode triggerMode, List<StudioEvent> events
});




}
/// @nodoc
class __$EventChainCopyWithImpl<$Res>
    implements _$EventChainCopyWith<$Res> {
  __$EventChainCopyWithImpl(this._self, this._then);

  final _EventChain _self;
  final $Res Function(_EventChain) _then;

/// Create a copy of EventChain
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? triggerMode = null,Object? events = null,}) {
  return _then(_EventChain(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,triggerMode: null == triggerMode ? _self.triggerMode : triggerMode // ignore: cast_nullable_to_non_nullable
as EventChainTriggerMode,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<StudioEvent>,
  ));
}


}

StudioEvent _$StudioEventFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'character.move':
          return CharacterMoveEvent.fromJson(
            json
          );
                case 'character.wait':
          return CharacterWaitEvent.fromJson(
            json
          );
                case 'character.changeExpression':
          return CharacterChangeExpressionEvent.fromJson(
            json
          );
                case 'character.startFollow':
          return CharacterStartFollowEvent.fromJson(
            json
          );
                case 'character.stopFollow':
          return CharacterStopFollowEvent.fromJson(
            json
          );
                case 'dialogue.say':
          return DialogueSayEvent.fromJson(
            json
          );
                case 'camera.follow':
          return CameraFollowEvent.fromJson(
            json
          );
                case 'camera.focus':
          return CameraFocusEvent.fromJson(
            json
          );
                case 'scene.fade':
          return SceneFadeEvent.fromJson(
            json
          );
                case 'scene.change':
          return SceneChangeEvent.fromJson(
            json
          );
                case 'audio.playBgm':
          return AudioPlayBgmEvent.fromJson(
            json
          );
                case 'audio.playSound':
          return AudioPlaySoundEvent.fromJson(
            json
          );
                case 'video.play':
          return VideoPlayEvent.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'StudioEvent',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$StudioEvent {

 String get id;
/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudioEventCopyWith<StudioEvent> get copyWith => _$StudioEventCopyWithImpl<StudioEvent>(this as StudioEvent, _$identity);

  /// Serializes this StudioEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudioEvent&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'StudioEvent(id: $id)';
}


}

/// @nodoc
abstract mixin class $StudioEventCopyWith<$Res>  {
  factory $StudioEventCopyWith(StudioEvent value, $Res Function(StudioEvent) _then) = _$StudioEventCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$StudioEventCopyWithImpl<$Res>
    implements $StudioEventCopyWith<$Res> {
  _$StudioEventCopyWithImpl(this._self, this._then);

  final StudioEvent _self;
  final $Res Function(StudioEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StudioEvent].
extension StudioEventPatterns on StudioEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CharacterMoveEvent value)?  characterMove,TResult Function( CharacterWaitEvent value)?  characterWait,TResult Function( CharacterChangeExpressionEvent value)?  characterChangeExpression,TResult Function( CharacterStartFollowEvent value)?  characterStartFollow,TResult Function( CharacterStopFollowEvent value)?  characterStopFollow,TResult Function( DialogueSayEvent value)?  dialogueSay,TResult Function( CameraFollowEvent value)?  cameraFollow,TResult Function( CameraFocusEvent value)?  cameraFocus,TResult Function( SceneFadeEvent value)?  sceneFade,TResult Function( SceneChangeEvent value)?  sceneChange,TResult Function( AudioPlayBgmEvent value)?  audioPlayBgm,TResult Function( AudioPlaySoundEvent value)?  audioPlaySound,TResult Function( VideoPlayEvent value)?  videoPlay,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CharacterMoveEvent() when characterMove != null:
return characterMove(_that);case CharacterWaitEvent() when characterWait != null:
return characterWait(_that);case CharacterChangeExpressionEvent() when characterChangeExpression != null:
return characterChangeExpression(_that);case CharacterStartFollowEvent() when characterStartFollow != null:
return characterStartFollow(_that);case CharacterStopFollowEvent() when characterStopFollow != null:
return characterStopFollow(_that);case DialogueSayEvent() when dialogueSay != null:
return dialogueSay(_that);case CameraFollowEvent() when cameraFollow != null:
return cameraFollow(_that);case CameraFocusEvent() when cameraFocus != null:
return cameraFocus(_that);case SceneFadeEvent() when sceneFade != null:
return sceneFade(_that);case SceneChangeEvent() when sceneChange != null:
return sceneChange(_that);case AudioPlayBgmEvent() when audioPlayBgm != null:
return audioPlayBgm(_that);case AudioPlaySoundEvent() when audioPlaySound != null:
return audioPlaySound(_that);case VideoPlayEvent() when videoPlay != null:
return videoPlay(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CharacterMoveEvent value)  characterMove,required TResult Function( CharacterWaitEvent value)  characterWait,required TResult Function( CharacterChangeExpressionEvent value)  characterChangeExpression,required TResult Function( CharacterStartFollowEvent value)  characterStartFollow,required TResult Function( CharacterStopFollowEvent value)  characterStopFollow,required TResult Function( DialogueSayEvent value)  dialogueSay,required TResult Function( CameraFollowEvent value)  cameraFollow,required TResult Function( CameraFocusEvent value)  cameraFocus,required TResult Function( SceneFadeEvent value)  sceneFade,required TResult Function( SceneChangeEvent value)  sceneChange,required TResult Function( AudioPlayBgmEvent value)  audioPlayBgm,required TResult Function( AudioPlaySoundEvent value)  audioPlaySound,required TResult Function( VideoPlayEvent value)  videoPlay,}){
final _that = this;
switch (_that) {
case CharacterMoveEvent():
return characterMove(_that);case CharacterWaitEvent():
return characterWait(_that);case CharacterChangeExpressionEvent():
return characterChangeExpression(_that);case CharacterStartFollowEvent():
return characterStartFollow(_that);case CharacterStopFollowEvent():
return characterStopFollow(_that);case DialogueSayEvent():
return dialogueSay(_that);case CameraFollowEvent():
return cameraFollow(_that);case CameraFocusEvent():
return cameraFocus(_that);case SceneFadeEvent():
return sceneFade(_that);case SceneChangeEvent():
return sceneChange(_that);case AudioPlayBgmEvent():
return audioPlayBgm(_that);case AudioPlaySoundEvent():
return audioPlaySound(_that);case VideoPlayEvent():
return videoPlay(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CharacterMoveEvent value)?  characterMove,TResult? Function( CharacterWaitEvent value)?  characterWait,TResult? Function( CharacterChangeExpressionEvent value)?  characterChangeExpression,TResult? Function( CharacterStartFollowEvent value)?  characterStartFollow,TResult? Function( CharacterStopFollowEvent value)?  characterStopFollow,TResult? Function( DialogueSayEvent value)?  dialogueSay,TResult? Function( CameraFollowEvent value)?  cameraFollow,TResult? Function( CameraFocusEvent value)?  cameraFocus,TResult? Function( SceneFadeEvent value)?  sceneFade,TResult? Function( SceneChangeEvent value)?  sceneChange,TResult? Function( AudioPlayBgmEvent value)?  audioPlayBgm,TResult? Function( AudioPlaySoundEvent value)?  audioPlaySound,TResult? Function( VideoPlayEvent value)?  videoPlay,}){
final _that = this;
switch (_that) {
case CharacterMoveEvent() when characterMove != null:
return characterMove(_that);case CharacterWaitEvent() when characterWait != null:
return characterWait(_that);case CharacterChangeExpressionEvent() when characterChangeExpression != null:
return characterChangeExpression(_that);case CharacterStartFollowEvent() when characterStartFollow != null:
return characterStartFollow(_that);case CharacterStopFollowEvent() when characterStopFollow != null:
return characterStopFollow(_that);case DialogueSayEvent() when dialogueSay != null:
return dialogueSay(_that);case CameraFollowEvent() when cameraFollow != null:
return cameraFollow(_that);case CameraFocusEvent() when cameraFocus != null:
return cameraFocus(_that);case SceneFadeEvent() when sceneFade != null:
return sceneFade(_that);case SceneChangeEvent() when sceneChange != null:
return sceneChange(_that);case AudioPlayBgmEvent() when audioPlayBgm != null:
return audioPlayBgm(_that);case AudioPlaySoundEvent() when audioPlaySound != null:
return audioPlaySound(_that);case VideoPlayEvent() when videoPlay != null:
return videoPlay(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String characterObjectId,  MovementPath path)?  characterMove,TResult Function( String id,  double duration)?  characterWait,TResult Function( String id,  String characterObjectId,  String expressionId)?  characterChangeExpression,TResult Function( String id,  String followerObjectId,  String leaderObjectId,  double distance)?  characterStartFollow,TResult Function( String id,  String followerObjectId)?  characterStopFollow,TResult Function( String id,  String text,  String? portraitAssetId,  String? textSoundAssetId,  DialogueStyle style,  double duration)?  dialogueSay,TResult Function( String id,  String targetObjectId)?  cameraFollow,TResult Function( String id,  FocusTarget target,  double duration)?  cameraFocus,TResult Function( String id,  FadeMode mode,  double duration)?  sceneFade,TResult Function( String id,  String sceneId,  String? entryPointId)?  sceneChange,TResult Function( String id,  String assetId)?  audioPlayBgm,TResult Function( String id,  String assetId)?  audioPlaySound,TResult Function( String id,  String assetId,  double duration,  VideoFitMode fit)?  videoPlay,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CharacterMoveEvent() when characterMove != null:
return characterMove(_that.id,_that.characterObjectId,_that.path);case CharacterWaitEvent() when characterWait != null:
return characterWait(_that.id,_that.duration);case CharacterChangeExpressionEvent() when characterChangeExpression != null:
return characterChangeExpression(_that.id,_that.characterObjectId,_that.expressionId);case CharacterStartFollowEvent() when characterStartFollow != null:
return characterStartFollow(_that.id,_that.followerObjectId,_that.leaderObjectId,_that.distance);case CharacterStopFollowEvent() when characterStopFollow != null:
return characterStopFollow(_that.id,_that.followerObjectId);case DialogueSayEvent() when dialogueSay != null:
return dialogueSay(_that.id,_that.text,_that.portraitAssetId,_that.textSoundAssetId,_that.style,_that.duration);case CameraFollowEvent() when cameraFollow != null:
return cameraFollow(_that.id,_that.targetObjectId);case CameraFocusEvent() when cameraFocus != null:
return cameraFocus(_that.id,_that.target,_that.duration);case SceneFadeEvent() when sceneFade != null:
return sceneFade(_that.id,_that.mode,_that.duration);case SceneChangeEvent() when sceneChange != null:
return sceneChange(_that.id,_that.sceneId,_that.entryPointId);case AudioPlayBgmEvent() when audioPlayBgm != null:
return audioPlayBgm(_that.id,_that.assetId);case AudioPlaySoundEvent() when audioPlaySound != null:
return audioPlaySound(_that.id,_that.assetId);case VideoPlayEvent() when videoPlay != null:
return videoPlay(_that.id,_that.assetId,_that.duration,_that.fit);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String characterObjectId,  MovementPath path)  characterMove,required TResult Function( String id,  double duration)  characterWait,required TResult Function( String id,  String characterObjectId,  String expressionId)  characterChangeExpression,required TResult Function( String id,  String followerObjectId,  String leaderObjectId,  double distance)  characterStartFollow,required TResult Function( String id,  String followerObjectId)  characterStopFollow,required TResult Function( String id,  String text,  String? portraitAssetId,  String? textSoundAssetId,  DialogueStyle style,  double duration)  dialogueSay,required TResult Function( String id,  String targetObjectId)  cameraFollow,required TResult Function( String id,  FocusTarget target,  double duration)  cameraFocus,required TResult Function( String id,  FadeMode mode,  double duration)  sceneFade,required TResult Function( String id,  String sceneId,  String? entryPointId)  sceneChange,required TResult Function( String id,  String assetId)  audioPlayBgm,required TResult Function( String id,  String assetId)  audioPlaySound,required TResult Function( String id,  String assetId,  double duration,  VideoFitMode fit)  videoPlay,}) {final _that = this;
switch (_that) {
case CharacterMoveEvent():
return characterMove(_that.id,_that.characterObjectId,_that.path);case CharacterWaitEvent():
return characterWait(_that.id,_that.duration);case CharacterChangeExpressionEvent():
return characterChangeExpression(_that.id,_that.characterObjectId,_that.expressionId);case CharacterStartFollowEvent():
return characterStartFollow(_that.id,_that.followerObjectId,_that.leaderObjectId,_that.distance);case CharacterStopFollowEvent():
return characterStopFollow(_that.id,_that.followerObjectId);case DialogueSayEvent():
return dialogueSay(_that.id,_that.text,_that.portraitAssetId,_that.textSoundAssetId,_that.style,_that.duration);case CameraFollowEvent():
return cameraFollow(_that.id,_that.targetObjectId);case CameraFocusEvent():
return cameraFocus(_that.id,_that.target,_that.duration);case SceneFadeEvent():
return sceneFade(_that.id,_that.mode,_that.duration);case SceneChangeEvent():
return sceneChange(_that.id,_that.sceneId,_that.entryPointId);case AudioPlayBgmEvent():
return audioPlayBgm(_that.id,_that.assetId);case AudioPlaySoundEvent():
return audioPlaySound(_that.id,_that.assetId);case VideoPlayEvent():
return videoPlay(_that.id,_that.assetId,_that.duration,_that.fit);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String characterObjectId,  MovementPath path)?  characterMove,TResult? Function( String id,  double duration)?  characterWait,TResult? Function( String id,  String characterObjectId,  String expressionId)?  characterChangeExpression,TResult? Function( String id,  String followerObjectId,  String leaderObjectId,  double distance)?  characterStartFollow,TResult? Function( String id,  String followerObjectId)?  characterStopFollow,TResult? Function( String id,  String text,  String? portraitAssetId,  String? textSoundAssetId,  DialogueStyle style,  double duration)?  dialogueSay,TResult? Function( String id,  String targetObjectId)?  cameraFollow,TResult? Function( String id,  FocusTarget target,  double duration)?  cameraFocus,TResult? Function( String id,  FadeMode mode,  double duration)?  sceneFade,TResult? Function( String id,  String sceneId,  String? entryPointId)?  sceneChange,TResult? Function( String id,  String assetId)?  audioPlayBgm,TResult? Function( String id,  String assetId)?  audioPlaySound,TResult? Function( String id,  String assetId,  double duration,  VideoFitMode fit)?  videoPlay,}) {final _that = this;
switch (_that) {
case CharacterMoveEvent() when characterMove != null:
return characterMove(_that.id,_that.characterObjectId,_that.path);case CharacterWaitEvent() when characterWait != null:
return characterWait(_that.id,_that.duration);case CharacterChangeExpressionEvent() when characterChangeExpression != null:
return characterChangeExpression(_that.id,_that.characterObjectId,_that.expressionId);case CharacterStartFollowEvent() when characterStartFollow != null:
return characterStartFollow(_that.id,_that.followerObjectId,_that.leaderObjectId,_that.distance);case CharacterStopFollowEvent() when characterStopFollow != null:
return characterStopFollow(_that.id,_that.followerObjectId);case DialogueSayEvent() when dialogueSay != null:
return dialogueSay(_that.id,_that.text,_that.portraitAssetId,_that.textSoundAssetId,_that.style,_that.duration);case CameraFollowEvent() when cameraFollow != null:
return cameraFollow(_that.id,_that.targetObjectId);case CameraFocusEvent() when cameraFocus != null:
return cameraFocus(_that.id,_that.target,_that.duration);case SceneFadeEvent() when sceneFade != null:
return sceneFade(_that.id,_that.mode,_that.duration);case SceneChangeEvent() when sceneChange != null:
return sceneChange(_that.id,_that.sceneId,_that.entryPointId);case AudioPlayBgmEvent() when audioPlayBgm != null:
return audioPlayBgm(_that.id,_that.assetId);case AudioPlaySoundEvent() when audioPlaySound != null:
return audioPlaySound(_that.id,_that.assetId);case VideoPlayEvent() when videoPlay != null:
return videoPlay(_that.id,_that.assetId,_that.duration,_that.fit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class CharacterMoveEvent extends StudioEvent {
  const CharacterMoveEvent({required this.id, required this.characterObjectId, required this.path,  String? $type}): $type = $type ?? 'character.move',super._();
  factory CharacterMoveEvent.fromJson(Map<String, dynamic> json) => _$CharacterMoveEventFromJson(json);

@override final  String id;
 final  String characterObjectId;
 final  MovementPath path;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterMoveEventCopyWith<CharacterMoveEvent> get copyWith => _$CharacterMoveEventCopyWithImpl<CharacterMoveEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CharacterMoveEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CharacterMoveEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.characterObjectId, characterObjectId) || other.characterObjectId == characterObjectId)&&(identical(other.path, path) || other.path == path));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,characterObjectId,path);

@override
String toString() {
  return 'StudioEvent.characterMove(id: $id, characterObjectId: $characterObjectId, path: $path)';
}


}

/// @nodoc
abstract mixin class $CharacterMoveEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $CharacterMoveEventCopyWith(CharacterMoveEvent value, $Res Function(CharacterMoveEvent) _then) = _$CharacterMoveEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String characterObjectId, MovementPath path
});


$MovementPathCopyWith<$Res> get path;

}
/// @nodoc
class _$CharacterMoveEventCopyWithImpl<$Res>
    implements $CharacterMoveEventCopyWith<$Res> {
  _$CharacterMoveEventCopyWithImpl(this._self, this._then);

  final CharacterMoveEvent _self;
  final $Res Function(CharacterMoveEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? characterObjectId = null,Object? path = null,}) {
  return _then(CharacterMoveEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,characterObjectId: null == characterObjectId ? _self.characterObjectId : characterObjectId // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as MovementPath,
  ));
}

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovementPathCopyWith<$Res> get path {
  
  return $MovementPathCopyWith<$Res>(_self.path, (value) {
    return _then(_self.copyWith(path: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class CharacterWaitEvent extends StudioEvent {
  const CharacterWaitEvent({required this.id, this.duration = 1,  String? $type}): $type = $type ?? 'character.wait',super._();
  factory CharacterWaitEvent.fromJson(Map<String, dynamic> json) => _$CharacterWaitEventFromJson(json);

@override final  String id;
@JsonKey() final  double duration;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterWaitEventCopyWith<CharacterWaitEvent> get copyWith => _$CharacterWaitEventCopyWithImpl<CharacterWaitEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CharacterWaitEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CharacterWaitEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,duration);

@override
String toString() {
  return 'StudioEvent.characterWait(id: $id, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $CharacterWaitEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $CharacterWaitEventCopyWith(CharacterWaitEvent value, $Res Function(CharacterWaitEvent) _then) = _$CharacterWaitEventCopyWithImpl;
@override @useResult
$Res call({
 String id, double duration
});




}
/// @nodoc
class _$CharacterWaitEventCopyWithImpl<$Res>
    implements $CharacterWaitEventCopyWith<$Res> {
  _$CharacterWaitEventCopyWithImpl(this._self, this._then);

  final CharacterWaitEvent _self;
  final $Res Function(CharacterWaitEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? duration = null,}) {
  return _then(CharacterWaitEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CharacterChangeExpressionEvent extends StudioEvent {
  const CharacterChangeExpressionEvent({required this.id, required this.characterObjectId, required this.expressionId,  String? $type}): $type = $type ?? 'character.changeExpression',super._();
  factory CharacterChangeExpressionEvent.fromJson(Map<String, dynamic> json) => _$CharacterChangeExpressionEventFromJson(json);

@override final  String id;
 final  String characterObjectId;
 final  String expressionId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterChangeExpressionEventCopyWith<CharacterChangeExpressionEvent> get copyWith => _$CharacterChangeExpressionEventCopyWithImpl<CharacterChangeExpressionEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CharacterChangeExpressionEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CharacterChangeExpressionEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.characterObjectId, characterObjectId) || other.characterObjectId == characterObjectId)&&(identical(other.expressionId, expressionId) || other.expressionId == expressionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,characterObjectId,expressionId);

@override
String toString() {
  return 'StudioEvent.characterChangeExpression(id: $id, characterObjectId: $characterObjectId, expressionId: $expressionId)';
}


}

/// @nodoc
abstract mixin class $CharacterChangeExpressionEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $CharacterChangeExpressionEventCopyWith(CharacterChangeExpressionEvent value, $Res Function(CharacterChangeExpressionEvent) _then) = _$CharacterChangeExpressionEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String characterObjectId, String expressionId
});




}
/// @nodoc
class _$CharacterChangeExpressionEventCopyWithImpl<$Res>
    implements $CharacterChangeExpressionEventCopyWith<$Res> {
  _$CharacterChangeExpressionEventCopyWithImpl(this._self, this._then);

  final CharacterChangeExpressionEvent _self;
  final $Res Function(CharacterChangeExpressionEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? characterObjectId = null,Object? expressionId = null,}) {
  return _then(CharacterChangeExpressionEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,characterObjectId: null == characterObjectId ? _self.characterObjectId : characterObjectId // ignore: cast_nullable_to_non_nullable
as String,expressionId: null == expressionId ? _self.expressionId : expressionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CharacterStartFollowEvent extends StudioEvent {
  const CharacterStartFollowEvent({required this.id, required this.followerObjectId, required this.leaderObjectId, this.distance = 48,  String? $type}): $type = $type ?? 'character.startFollow',super._();
  factory CharacterStartFollowEvent.fromJson(Map<String, dynamic> json) => _$CharacterStartFollowEventFromJson(json);

@override final  String id;
 final  String followerObjectId;
 final  String leaderObjectId;
@JsonKey() final  double distance;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterStartFollowEventCopyWith<CharacterStartFollowEvent> get copyWith => _$CharacterStartFollowEventCopyWithImpl<CharacterStartFollowEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CharacterStartFollowEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CharacterStartFollowEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.followerObjectId, followerObjectId) || other.followerObjectId == followerObjectId)&&(identical(other.leaderObjectId, leaderObjectId) || other.leaderObjectId == leaderObjectId)&&(identical(other.distance, distance) || other.distance == distance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,followerObjectId,leaderObjectId,distance);

@override
String toString() {
  return 'StudioEvent.characterStartFollow(id: $id, followerObjectId: $followerObjectId, leaderObjectId: $leaderObjectId, distance: $distance)';
}


}

/// @nodoc
abstract mixin class $CharacterStartFollowEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $CharacterStartFollowEventCopyWith(CharacterStartFollowEvent value, $Res Function(CharacterStartFollowEvent) _then) = _$CharacterStartFollowEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String followerObjectId, String leaderObjectId, double distance
});




}
/// @nodoc
class _$CharacterStartFollowEventCopyWithImpl<$Res>
    implements $CharacterStartFollowEventCopyWith<$Res> {
  _$CharacterStartFollowEventCopyWithImpl(this._self, this._then);

  final CharacterStartFollowEvent _self;
  final $Res Function(CharacterStartFollowEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? followerObjectId = null,Object? leaderObjectId = null,Object? distance = null,}) {
  return _then(CharacterStartFollowEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,followerObjectId: null == followerObjectId ? _self.followerObjectId : followerObjectId // ignore: cast_nullable_to_non_nullable
as String,leaderObjectId: null == leaderObjectId ? _self.leaderObjectId : leaderObjectId // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CharacterStopFollowEvent extends StudioEvent {
  const CharacterStopFollowEvent({required this.id, required this.followerObjectId,  String? $type}): $type = $type ?? 'character.stopFollow',super._();
  factory CharacterStopFollowEvent.fromJson(Map<String, dynamic> json) => _$CharacterStopFollowEventFromJson(json);

@override final  String id;
 final  String followerObjectId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterStopFollowEventCopyWith<CharacterStopFollowEvent> get copyWith => _$CharacterStopFollowEventCopyWithImpl<CharacterStopFollowEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CharacterStopFollowEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CharacterStopFollowEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.followerObjectId, followerObjectId) || other.followerObjectId == followerObjectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,followerObjectId);

@override
String toString() {
  return 'StudioEvent.characterStopFollow(id: $id, followerObjectId: $followerObjectId)';
}


}

/// @nodoc
abstract mixin class $CharacterStopFollowEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $CharacterStopFollowEventCopyWith(CharacterStopFollowEvent value, $Res Function(CharacterStopFollowEvent) _then) = _$CharacterStopFollowEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String followerObjectId
});




}
/// @nodoc
class _$CharacterStopFollowEventCopyWithImpl<$Res>
    implements $CharacterStopFollowEventCopyWith<$Res> {
  _$CharacterStopFollowEventCopyWithImpl(this._self, this._then);

  final CharacterStopFollowEvent _self;
  final $Res Function(CharacterStopFollowEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? followerObjectId = null,}) {
  return _then(CharacterStopFollowEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,followerObjectId: null == followerObjectId ? _self.followerObjectId : followerObjectId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class DialogueSayEvent extends StudioEvent {
  const DialogueSayEvent({required this.id, required this.text, this.portraitAssetId, this.textSoundAssetId, this.style = DialogueStyle.regular, this.duration = 2,  String? $type}): $type = $type ?? 'dialogue.say',super._();
  factory DialogueSayEvent.fromJson(Map<String, dynamic> json) => _$DialogueSayEventFromJson(json);

@override final  String id;
 final  String text;
 final  String? portraitAssetId;
 final  String? textSoundAssetId;
@JsonKey() final  DialogueStyle style;
@JsonKey() final  double duration;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DialogueSayEventCopyWith<DialogueSayEvent> get copyWith => _$DialogueSayEventCopyWithImpl<DialogueSayEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DialogueSayEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DialogueSayEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.portraitAssetId, portraitAssetId) || other.portraitAssetId == portraitAssetId)&&(identical(other.textSoundAssetId, textSoundAssetId) || other.textSoundAssetId == textSoundAssetId)&&(identical(other.style, style) || other.style == style)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,portraitAssetId,textSoundAssetId,style,duration);

@override
String toString() {
  return 'StudioEvent.dialogueSay(id: $id, text: $text, portraitAssetId: $portraitAssetId, textSoundAssetId: $textSoundAssetId, style: $style, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $DialogueSayEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $DialogueSayEventCopyWith(DialogueSayEvent value, $Res Function(DialogueSayEvent) _then) = _$DialogueSayEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, String? portraitAssetId, String? textSoundAssetId, DialogueStyle style, double duration
});




}
/// @nodoc
class _$DialogueSayEventCopyWithImpl<$Res>
    implements $DialogueSayEventCopyWith<$Res> {
  _$DialogueSayEventCopyWithImpl(this._self, this._then);

  final DialogueSayEvent _self;
  final $Res Function(DialogueSayEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? portraitAssetId = freezed,Object? textSoundAssetId = freezed,Object? style = null,Object? duration = null,}) {
  return _then(DialogueSayEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,portraitAssetId: freezed == portraitAssetId ? _self.portraitAssetId : portraitAssetId // ignore: cast_nullable_to_non_nullable
as String?,textSoundAssetId: freezed == textSoundAssetId ? _self.textSoundAssetId : textSoundAssetId // ignore: cast_nullable_to_non_nullable
as String?,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as DialogueStyle,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CameraFollowEvent extends StudioEvent {
  const CameraFollowEvent({required this.id, required this.targetObjectId,  String? $type}): $type = $type ?? 'camera.follow',super._();
  factory CameraFollowEvent.fromJson(Map<String, dynamic> json) => _$CameraFollowEventFromJson(json);

@override final  String id;
 final  String targetObjectId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraFollowEventCopyWith<CameraFollowEvent> get copyWith => _$CameraFollowEventCopyWithImpl<CameraFollowEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CameraFollowEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraFollowEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.targetObjectId, targetObjectId) || other.targetObjectId == targetObjectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,targetObjectId);

@override
String toString() {
  return 'StudioEvent.cameraFollow(id: $id, targetObjectId: $targetObjectId)';
}


}

/// @nodoc
abstract mixin class $CameraFollowEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $CameraFollowEventCopyWith(CameraFollowEvent value, $Res Function(CameraFollowEvent) _then) = _$CameraFollowEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String targetObjectId
});




}
/// @nodoc
class _$CameraFollowEventCopyWithImpl<$Res>
    implements $CameraFollowEventCopyWith<$Res> {
  _$CameraFollowEventCopyWithImpl(this._self, this._then);

  final CameraFollowEvent _self;
  final $Res Function(CameraFollowEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? targetObjectId = null,}) {
  return _then(CameraFollowEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetObjectId: null == targetObjectId ? _self.targetObjectId : targetObjectId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CameraFocusEvent extends StudioEvent {
  const CameraFocusEvent({required this.id, required this.target, this.duration = 0.5,  String? $type}): $type = $type ?? 'camera.focus',super._();
  factory CameraFocusEvent.fromJson(Map<String, dynamic> json) => _$CameraFocusEventFromJson(json);

@override final  String id;
 final  FocusTarget target;
@JsonKey() final  double duration;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraFocusEventCopyWith<CameraFocusEvent> get copyWith => _$CameraFocusEventCopyWithImpl<CameraFocusEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CameraFocusEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraFocusEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.target, target) || other.target == target)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,target,duration);

@override
String toString() {
  return 'StudioEvent.cameraFocus(id: $id, target: $target, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $CameraFocusEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $CameraFocusEventCopyWith(CameraFocusEvent value, $Res Function(CameraFocusEvent) _then) = _$CameraFocusEventCopyWithImpl;
@override @useResult
$Res call({
 String id, FocusTarget target, double duration
});


$FocusTargetCopyWith<$Res> get target;

}
/// @nodoc
class _$CameraFocusEventCopyWithImpl<$Res>
    implements $CameraFocusEventCopyWith<$Res> {
  _$CameraFocusEventCopyWithImpl(this._self, this._then);

  final CameraFocusEvent _self;
  final $Res Function(CameraFocusEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? target = null,Object? duration = null,}) {
  return _then(CameraFocusEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as FocusTarget,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FocusTargetCopyWith<$Res> get target {
  
  return $FocusTargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class SceneFadeEvent extends StudioEvent {
  const SceneFadeEvent({required this.id, required this.mode, this.duration = 0.8,  String? $type}): $type = $type ?? 'scene.fade',super._();
  factory SceneFadeEvent.fromJson(Map<String, dynamic> json) => _$SceneFadeEventFromJson(json);

@override final  String id;
 final  FadeMode mode;
@JsonKey() final  double duration;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneFadeEventCopyWith<SceneFadeEvent> get copyWith => _$SceneFadeEventCopyWithImpl<SceneFadeEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneFadeEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneFadeEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mode,duration);

@override
String toString() {
  return 'StudioEvent.sceneFade(id: $id, mode: $mode, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $SceneFadeEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $SceneFadeEventCopyWith(SceneFadeEvent value, $Res Function(SceneFadeEvent) _then) = _$SceneFadeEventCopyWithImpl;
@override @useResult
$Res call({
 String id, FadeMode mode, double duration
});




}
/// @nodoc
class _$SceneFadeEventCopyWithImpl<$Res>
    implements $SceneFadeEventCopyWith<$Res> {
  _$SceneFadeEventCopyWithImpl(this._self, this._then);

  final SceneFadeEvent _self;
  final $Res Function(SceneFadeEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? mode = null,Object? duration = null,}) {
  return _then(SceneFadeEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as FadeMode,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SceneChangeEvent extends StudioEvent {
  const SceneChangeEvent({required this.id, required this.sceneId, this.entryPointId,  String? $type}): $type = $type ?? 'scene.change',super._();
  factory SceneChangeEvent.fromJson(Map<String, dynamic> json) => _$SceneChangeEventFromJson(json);

@override final  String id;
 final  String sceneId;
 final  String? entryPointId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneChangeEventCopyWith<SceneChangeEvent> get copyWith => _$SceneChangeEventCopyWithImpl<SceneChangeEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneChangeEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneChangeEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.entryPointId, entryPointId) || other.entryPointId == entryPointId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sceneId,entryPointId);

@override
String toString() {
  return 'StudioEvent.sceneChange(id: $id, sceneId: $sceneId, entryPointId: $entryPointId)';
}


}

/// @nodoc
abstract mixin class $SceneChangeEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $SceneChangeEventCopyWith(SceneChangeEvent value, $Res Function(SceneChangeEvent) _then) = _$SceneChangeEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String sceneId, String? entryPointId
});




}
/// @nodoc
class _$SceneChangeEventCopyWithImpl<$Res>
    implements $SceneChangeEventCopyWith<$Res> {
  _$SceneChangeEventCopyWithImpl(this._self, this._then);

  final SceneChangeEvent _self;
  final $Res Function(SceneChangeEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sceneId = null,Object? entryPointId = freezed,}) {
  return _then(SceneChangeEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sceneId: null == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as String,entryPointId: freezed == entryPointId ? _self.entryPointId : entryPointId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AudioPlayBgmEvent extends StudioEvent {
  const AudioPlayBgmEvent({required this.id, required this.assetId,  String? $type}): $type = $type ?? 'audio.playBgm',super._();
  factory AudioPlayBgmEvent.fromJson(Map<String, dynamic> json) => _$AudioPlayBgmEventFromJson(json);

@override final  String id;
 final  String assetId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudioPlayBgmEventCopyWith<AudioPlayBgmEvent> get copyWith => _$AudioPlayBgmEventCopyWithImpl<AudioPlayBgmEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AudioPlayBgmEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioPlayBgmEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.assetId, assetId) || other.assetId == assetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,assetId);

@override
String toString() {
  return 'StudioEvent.audioPlayBgm(id: $id, assetId: $assetId)';
}


}

/// @nodoc
abstract mixin class $AudioPlayBgmEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $AudioPlayBgmEventCopyWith(AudioPlayBgmEvent value, $Res Function(AudioPlayBgmEvent) _then) = _$AudioPlayBgmEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String assetId
});




}
/// @nodoc
class _$AudioPlayBgmEventCopyWithImpl<$Res>
    implements $AudioPlayBgmEventCopyWith<$Res> {
  _$AudioPlayBgmEventCopyWithImpl(this._self, this._then);

  final AudioPlayBgmEvent _self;
  final $Res Function(AudioPlayBgmEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetId = null,}) {
  return _then(AudioPlayBgmEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AudioPlaySoundEvent extends StudioEvent {
  const AudioPlaySoundEvent({required this.id, required this.assetId,  String? $type}): $type = $type ?? 'audio.playSound',super._();
  factory AudioPlaySoundEvent.fromJson(Map<String, dynamic> json) => _$AudioPlaySoundEventFromJson(json);

@override final  String id;
 final  String assetId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudioPlaySoundEventCopyWith<AudioPlaySoundEvent> get copyWith => _$AudioPlaySoundEventCopyWithImpl<AudioPlaySoundEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AudioPlaySoundEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioPlaySoundEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.assetId, assetId) || other.assetId == assetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,assetId);

@override
String toString() {
  return 'StudioEvent.audioPlaySound(id: $id, assetId: $assetId)';
}


}

/// @nodoc
abstract mixin class $AudioPlaySoundEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $AudioPlaySoundEventCopyWith(AudioPlaySoundEvent value, $Res Function(AudioPlaySoundEvent) _then) = _$AudioPlaySoundEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String assetId
});




}
/// @nodoc
class _$AudioPlaySoundEventCopyWithImpl<$Res>
    implements $AudioPlaySoundEventCopyWith<$Res> {
  _$AudioPlaySoundEventCopyWithImpl(this._self, this._then);

  final AudioPlaySoundEvent _self;
  final $Res Function(AudioPlaySoundEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetId = null,}) {
  return _then(AudioPlaySoundEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class VideoPlayEvent extends StudioEvent {
  const VideoPlayEvent({required this.id, required this.assetId, this.duration = 3, this.fit = VideoFitMode.contain,  String? $type}): $type = $type ?? 'video.play',super._();
  factory VideoPlayEvent.fromJson(Map<String, dynamic> json) => _$VideoPlayEventFromJson(json);

@override final  String id;
 final  String assetId;
@JsonKey() final  double duration;
@JsonKey() final  VideoFitMode fit;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoPlayEventCopyWith<VideoPlayEvent> get copyWith => _$VideoPlayEventCopyWithImpl<VideoPlayEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoPlayEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoPlayEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.fit, fit) || other.fit == fit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,assetId,duration,fit);

@override
String toString() {
  return 'StudioEvent.videoPlay(id: $id, assetId: $assetId, duration: $duration, fit: $fit)';
}


}

/// @nodoc
abstract mixin class $VideoPlayEventCopyWith<$Res> implements $StudioEventCopyWith<$Res> {
  factory $VideoPlayEventCopyWith(VideoPlayEvent value, $Res Function(VideoPlayEvent) _then) = _$VideoPlayEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String assetId, double duration, VideoFitMode fit
});




}
/// @nodoc
class _$VideoPlayEventCopyWithImpl<$Res>
    implements $VideoPlayEventCopyWith<$Res> {
  _$VideoPlayEventCopyWithImpl(this._self, this._then);

  final VideoPlayEvent _self;
  final $Res Function(VideoPlayEvent) _then;

/// Create a copy of StudioEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetId = null,Object? duration = null,Object? fit = null,}) {
  return _then(VideoPlayEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,fit: null == fit ? _self.fit : fit // ignore: cast_nullable_to_non_nullable
as VideoFitMode,
  ));
}


}

CameraPolicy _$CameraPolicyFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'followPlayer':
          return FollowPlayerCameraPolicy.fromJson(
            json
          );
                case 'focus':
          return FocusCameraPolicy.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'CameraPolicy',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$CameraPolicy {



  /// Serializes this CameraPolicy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraPolicy);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CameraPolicy()';
}


}

/// @nodoc
class $CameraPolicyCopyWith<$Res>  {
$CameraPolicyCopyWith(CameraPolicy _, $Res Function(CameraPolicy) __);
}


/// Adds pattern-matching-related methods to [CameraPolicy].
extension CameraPolicyPatterns on CameraPolicy {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FollowPlayerCameraPolicy value)?  followPlayer,TResult Function( FocusCameraPolicy value)?  focus,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FollowPlayerCameraPolicy() when followPlayer != null:
return followPlayer(_that);case FocusCameraPolicy() when focus != null:
return focus(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FollowPlayerCameraPolicy value)  followPlayer,required TResult Function( FocusCameraPolicy value)  focus,}){
final _that = this;
switch (_that) {
case FollowPlayerCameraPolicy():
return followPlayer(_that);case FocusCameraPolicy():
return focus(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FollowPlayerCameraPolicy value)?  followPlayer,TResult? Function( FocusCameraPolicy value)?  focus,}){
final _that = this;
switch (_that) {
case FollowPlayerCameraPolicy() when followPlayer != null:
return followPlayer(_that);case FocusCameraPolicy() when focus != null:
return focus(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String playerObjectId)?  followPlayer,TResult Function( FocusTarget target)?  focus,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FollowPlayerCameraPolicy() when followPlayer != null:
return followPlayer(_that.playerObjectId);case FocusCameraPolicy() when focus != null:
return focus(_that.target);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String playerObjectId)  followPlayer,required TResult Function( FocusTarget target)  focus,}) {final _that = this;
switch (_that) {
case FollowPlayerCameraPolicy():
return followPlayer(_that.playerObjectId);case FocusCameraPolicy():
return focus(_that.target);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String playerObjectId)?  followPlayer,TResult? Function( FocusTarget target)?  focus,}) {final _that = this;
switch (_that) {
case FollowPlayerCameraPolicy() when followPlayer != null:
return followPlayer(_that.playerObjectId);case FocusCameraPolicy() when focus != null:
return focus(_that.target);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class FollowPlayerCameraPolicy implements CameraPolicy {
  const FollowPlayerCameraPolicy({required this.playerObjectId,  String? $type}): $type = $type ?? 'followPlayer';
  factory FollowPlayerCameraPolicy.fromJson(Map<String, dynamic> json) => _$FollowPlayerCameraPolicyFromJson(json);

 final  String playerObjectId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of CameraPolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowPlayerCameraPolicyCopyWith<FollowPlayerCameraPolicy> get copyWith => _$FollowPlayerCameraPolicyCopyWithImpl<FollowPlayerCameraPolicy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowPlayerCameraPolicyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowPlayerCameraPolicy&&(identical(other.playerObjectId, playerObjectId) || other.playerObjectId == playerObjectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerObjectId);

@override
String toString() {
  return 'CameraPolicy.followPlayer(playerObjectId: $playerObjectId)';
}


}

/// @nodoc
abstract mixin class $FollowPlayerCameraPolicyCopyWith<$Res> implements $CameraPolicyCopyWith<$Res> {
  factory $FollowPlayerCameraPolicyCopyWith(FollowPlayerCameraPolicy value, $Res Function(FollowPlayerCameraPolicy) _then) = _$FollowPlayerCameraPolicyCopyWithImpl;
@useResult
$Res call({
 String playerObjectId
});




}
/// @nodoc
class _$FollowPlayerCameraPolicyCopyWithImpl<$Res>
    implements $FollowPlayerCameraPolicyCopyWith<$Res> {
  _$FollowPlayerCameraPolicyCopyWithImpl(this._self, this._then);

  final FollowPlayerCameraPolicy _self;
  final $Res Function(FollowPlayerCameraPolicy) _then;

/// Create a copy of CameraPolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? playerObjectId = null,}) {
  return _then(FollowPlayerCameraPolicy(
playerObjectId: null == playerObjectId ? _self.playerObjectId : playerObjectId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class FocusCameraPolicy implements CameraPolicy {
  const FocusCameraPolicy({required this.target,  String? $type}): $type = $type ?? 'focus';
  factory FocusCameraPolicy.fromJson(Map<String, dynamic> json) => _$FocusCameraPolicyFromJson(json);

 final  FocusTarget target;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of CameraPolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FocusCameraPolicyCopyWith<FocusCameraPolicy> get copyWith => _$FocusCameraPolicyCopyWithImpl<FocusCameraPolicy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FocusCameraPolicyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FocusCameraPolicy&&(identical(other.target, target) || other.target == target));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,target);

@override
String toString() {
  return 'CameraPolicy.focus(target: $target)';
}


}

/// @nodoc
abstract mixin class $FocusCameraPolicyCopyWith<$Res> implements $CameraPolicyCopyWith<$Res> {
  factory $FocusCameraPolicyCopyWith(FocusCameraPolicy value, $Res Function(FocusCameraPolicy) _then) = _$FocusCameraPolicyCopyWithImpl;
@useResult
$Res call({
 FocusTarget target
});


$FocusTargetCopyWith<$Res> get target;

}
/// @nodoc
class _$FocusCameraPolicyCopyWithImpl<$Res>
    implements $FocusCameraPolicyCopyWith<$Res> {
  _$FocusCameraPolicyCopyWithImpl(this._self, this._then);

  final FocusCameraPolicy _self;
  final $Res Function(FocusCameraPolicy) _then;

/// Create a copy of CameraPolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? target = null,}) {
  return _then(FocusCameraPolicy(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as FocusTarget,
  ));
}

/// Create a copy of CameraPolicy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FocusTargetCopyWith<$Res> get target {
  
  return $FocusTargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}

FocusTarget _$FocusTargetFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'object':
          return ObjectFocusTarget.fromJson(
            json
          );
                case 'point':
          return PointFocusTarget.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'FocusTarget',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$FocusTarget {



  /// Serializes this FocusTarget to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FocusTarget);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FocusTarget()';
}


}

/// @nodoc
class $FocusTargetCopyWith<$Res>  {
$FocusTargetCopyWith(FocusTarget _, $Res Function(FocusTarget) __);
}


/// Adds pattern-matching-related methods to [FocusTarget].
extension FocusTargetPatterns on FocusTarget {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ObjectFocusTarget value)?  object,TResult Function( PointFocusTarget value)?  point,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ObjectFocusTarget() when object != null:
return object(_that);case PointFocusTarget() when point != null:
return point(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ObjectFocusTarget value)  object,required TResult Function( PointFocusTarget value)  point,}){
final _that = this;
switch (_that) {
case ObjectFocusTarget():
return object(_that);case PointFocusTarget():
return point(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ObjectFocusTarget value)?  object,TResult? Function( PointFocusTarget value)?  point,}){
final _that = this;
switch (_that) {
case ObjectFocusTarget() when object != null:
return object(_that);case PointFocusTarget() when point != null:
return point(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String objectId)?  object,TResult Function( double x,  double y)?  point,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ObjectFocusTarget() when object != null:
return object(_that.objectId);case PointFocusTarget() when point != null:
return point(_that.x,_that.y);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String objectId)  object,required TResult Function( double x,  double y)  point,}) {final _that = this;
switch (_that) {
case ObjectFocusTarget():
return object(_that.objectId);case PointFocusTarget():
return point(_that.x,_that.y);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String objectId)?  object,TResult? Function( double x,  double y)?  point,}) {final _that = this;
switch (_that) {
case ObjectFocusTarget() when object != null:
return object(_that.objectId);case PointFocusTarget() when point != null:
return point(_that.x,_that.y);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class ObjectFocusTarget implements FocusTarget {
  const ObjectFocusTarget({required this.objectId,  String? $type}): $type = $type ?? 'object';
  factory ObjectFocusTarget.fromJson(Map<String, dynamic> json) => _$ObjectFocusTargetFromJson(json);

 final  String objectId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FocusTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ObjectFocusTargetCopyWith<ObjectFocusTarget> get copyWith => _$ObjectFocusTargetCopyWithImpl<ObjectFocusTarget>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ObjectFocusTargetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ObjectFocusTarget&&(identical(other.objectId, objectId) || other.objectId == objectId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,objectId);

@override
String toString() {
  return 'FocusTarget.object(objectId: $objectId)';
}


}

/// @nodoc
abstract mixin class $ObjectFocusTargetCopyWith<$Res> implements $FocusTargetCopyWith<$Res> {
  factory $ObjectFocusTargetCopyWith(ObjectFocusTarget value, $Res Function(ObjectFocusTarget) _then) = _$ObjectFocusTargetCopyWithImpl;
@useResult
$Res call({
 String objectId
});




}
/// @nodoc
class _$ObjectFocusTargetCopyWithImpl<$Res>
    implements $ObjectFocusTargetCopyWith<$Res> {
  _$ObjectFocusTargetCopyWithImpl(this._self, this._then);

  final ObjectFocusTarget _self;
  final $Res Function(ObjectFocusTarget) _then;

/// Create a copy of FocusTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? objectId = null,}) {
  return _then(ObjectFocusTarget(
objectId: null == objectId ? _self.objectId : objectId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PointFocusTarget implements FocusTarget {
  const PointFocusTarget({required this.x, required this.y,  String? $type}): $type = $type ?? 'point';
  factory PointFocusTarget.fromJson(Map<String, dynamic> json) => _$PointFocusTargetFromJson(json);

 final  double x;
 final  double y;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of FocusTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PointFocusTargetCopyWith<PointFocusTarget> get copyWith => _$PointFocusTargetCopyWithImpl<PointFocusTarget>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PointFocusTargetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PointFocusTarget&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y);

@override
String toString() {
  return 'FocusTarget.point(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class $PointFocusTargetCopyWith<$Res> implements $FocusTargetCopyWith<$Res> {
  factory $PointFocusTargetCopyWith(PointFocusTarget value, $Res Function(PointFocusTarget) _then) = _$PointFocusTargetCopyWithImpl;
@useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class _$PointFocusTargetCopyWithImpl<$Res>
    implements $PointFocusTargetCopyWith<$Res> {
  _$PointFocusTargetCopyWithImpl(this._self, this._then);

  final PointFocusTarget _self;
  final $Res Function(PointFocusTarget) _then;

/// Create a copy of FocusTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,}) {
  return _then(PointFocusTarget(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$BattleRequest {

 String get encounterId; String get returnSceneId; String get returnMarkerId;
/// Create a copy of BattleRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BattleRequestCopyWith<BattleRequest> get copyWith => _$BattleRequestCopyWithImpl<BattleRequest>(this as BattleRequest, _$identity);

  /// Serializes this BattleRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BattleRequest&&(identical(other.encounterId, encounterId) || other.encounterId == encounterId)&&(identical(other.returnSceneId, returnSceneId) || other.returnSceneId == returnSceneId)&&(identical(other.returnMarkerId, returnMarkerId) || other.returnMarkerId == returnMarkerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,encounterId,returnSceneId,returnMarkerId);

@override
String toString() {
  return 'BattleRequest(encounterId: $encounterId, returnSceneId: $returnSceneId, returnMarkerId: $returnMarkerId)';
}


}

/// @nodoc
abstract mixin class $BattleRequestCopyWith<$Res>  {
  factory $BattleRequestCopyWith(BattleRequest value, $Res Function(BattleRequest) _then) = _$BattleRequestCopyWithImpl;
@useResult
$Res call({
 String encounterId, String returnSceneId, String returnMarkerId
});




}
/// @nodoc
class _$BattleRequestCopyWithImpl<$Res>
    implements $BattleRequestCopyWith<$Res> {
  _$BattleRequestCopyWithImpl(this._self, this._then);

  final BattleRequest _self;
  final $Res Function(BattleRequest) _then;

/// Create a copy of BattleRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? encounterId = null,Object? returnSceneId = null,Object? returnMarkerId = null,}) {
  return _then(BattleRequest(
encounterId: null == encounterId ? _self.encounterId : encounterId // ignore: cast_nullable_to_non_nullable
as String,returnSceneId: null == returnSceneId ? _self.returnSceneId : returnSceneId // ignore: cast_nullable_to_non_nullable
as String,returnMarkerId: null == returnMarkerId ? _self.returnMarkerId : returnMarkerId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BattleRequest].
extension BattleRequestPatterns on BattleRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BattleRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BattleRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BattleRequest value)  $default,){
final _that = this;
switch (_that) {
case _BattleRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BattleRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BattleRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String encounterId,  String returnSceneId,  String returnMarkerId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BattleRequest() when $default != null:
return $default(_that.encounterId,_that.returnSceneId,_that.returnMarkerId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String encounterId,  String returnSceneId,  String returnMarkerId)  $default,) {final _that = this;
switch (_that) {
case _BattleRequest():
return $default(_that.encounterId,_that.returnSceneId,_that.returnMarkerId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String encounterId,  String returnSceneId,  String returnMarkerId)?  $default,) {final _that = this;
switch (_that) {
case _BattleRequest() when $default != null:
return $default(_that.encounterId,_that.returnSceneId,_that.returnMarkerId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BattleRequest implements BattleRequest {
  const _BattleRequest({required this.encounterId, required this.returnSceneId, required this.returnMarkerId});
  factory _BattleRequest.fromJson(Map<String, dynamic> json) => _$BattleRequestFromJson(json);

@override final  String encounterId;
@override final  String returnSceneId;
@override final  String returnMarkerId;

/// Create a copy of BattleRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BattleRequestCopyWith<_BattleRequest> get copyWith => __$BattleRequestCopyWithImpl<_BattleRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BattleRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BattleRequest&&(identical(other.encounterId, encounterId) || other.encounterId == encounterId)&&(identical(other.returnSceneId, returnSceneId) || other.returnSceneId == returnSceneId)&&(identical(other.returnMarkerId, returnMarkerId) || other.returnMarkerId == returnMarkerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,encounterId,returnSceneId,returnMarkerId);

@override
String toString() {
  return 'BattleRequest(encounterId: $encounterId, returnSceneId: $returnSceneId, returnMarkerId: $returnMarkerId)';
}


}

/// @nodoc
abstract mixin class _$BattleRequestCopyWith<$Res> implements $BattleRequestCopyWith<$Res> {
  factory _$BattleRequestCopyWith(_BattleRequest value, $Res Function(_BattleRequest) _then) = __$BattleRequestCopyWithImpl;
@override @useResult
$Res call({
 String encounterId, String returnSceneId, String returnMarkerId
});




}
/// @nodoc
class __$BattleRequestCopyWithImpl<$Res>
    implements _$BattleRequestCopyWith<$Res> {
  __$BattleRequestCopyWithImpl(this._self, this._then);

  final _BattleRequest _self;
  final $Res Function(_BattleRequest) _then;

/// Create a copy of BattleRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? encounterId = null,Object? returnSceneId = null,Object? returnMarkerId = null,}) {
  return _then(_BattleRequest(
encounterId: null == encounterId ? _self.encounterId : encounterId // ignore: cast_nullable_to_non_nullable
as String,returnSceneId: null == returnSceneId ? _self.returnSceneId : returnSceneId // ignore: cast_nullable_to_non_nullable
as String,returnMarkerId: null == returnMarkerId ? _self.returnMarkerId : returnMarkerId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
